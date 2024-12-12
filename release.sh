#!/bin/bash 

# Set up the environment correctly
export PATH="/usr/local/bundle/bin:$PATH"

# Step 1: Clear the database
echo "Dropping existing database..."
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:drop
if [ $? -ne 0 ]; then
  echo "Database drop failed. Aborting release process."
  exit 1
fi

# Step 2: Create the database
echo "Creating database..."
bundle exec rails db:create
if [ $? -ne 0 ]; then
  echo "Database creation failed. Aborting release process."
  exit 1
fi

# Step 3: Run database migrations
echo "Running migrations..."
bundle exec rails db:migrate
if [ $? -ne 0 ]; then
  echo "Database migration failed. Aborting release process."
  exit 1
fi

# Step 4: Run the DataGouvApiService to gather data
echo "Starting data gathering from DataGouv API..."
bundle exec rails runner "DataGouvApiService.new.gather_data"
if [ $? -ne 0 ]; then
  echo "Data gathering failed. Aborting release process."
  exit 1
fi

# Step 5: Run the PoliticianPdfService for all Politicians
echo "Starting PDF analysis for all politicians..."
bundle exec rails runner "
  Politician.find_each do |politician|
    puts \"Processing: \#{politician.first_name} \#{politician.last_name}\"
    begin
      PoliticianPdfService.new(politician).fetch_and_analyze_pdf
    rescue => e
      puts \"Error processing \#{politician.first_name} \#{politician.last_name}: \#{e.message}\"
    end
  end
"
if [ $? -ne 0 ]; then
  echo "PDF analysis for politicians failed."
  exit 1
fi

# Step 6: Run the French encoding cleanup
echo "Starting French encoding cleanup..."
bundle exec rails runner "require_relative 'fr_encoding_cleanup'"
if [ $? -ne 0 ]; then
  echo "French encoding cleanup failed. Aborting release process."
  exit 1
fi

# Final message
echo "Release process completed successfully."