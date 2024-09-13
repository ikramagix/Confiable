#!/bin/bash

# Set up the environment correctly
export PATH="/usr/local/bundle/bin:$PATH"

# Prepare the database
bundle exec rails db:prepare

# Check if the previous command was successful
if [ $? -ne 0 ]; then
  echo "Database preparation failed, aborting data gathering."
  exit 1
fi

# Run the data gathering task using bundle exec to ensure the correct environment
bundle exec rails data_gouv:gather_data

# Check if the data gathering was successful
if [ $? -ne 0 ]; then
  echo "Data gathering failed."
  exit 1
fi

echo "Starting deployment and data fetching..."

# Loop through all politicians and perform the PDF analysis
echo "Running analysis for all politicians..."
bundle exec rails runner "
  Politician.find_each do |politician|
    puts 'Processing: ' + politician.first_name + ' ' + politician.last_name
    begin
      PoliticianPdfService.new(politician).fetch_and_analyze_pdf
    rescue => e
      puts 'Error processing ' + politician.first_name + ' ' + politician.last_name + ': ' + e.message
    end
  end
"

# Check if the analysis was successful
if [ $? -ne 0 ]; then
  echo "PDF analysis for politicians failed."
  exit 1
fi

echo "Deployment and data fetching completed successfully."
