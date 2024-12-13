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

# Step 4: Run the DataGouvApiService in the background
echo "Starting data gathering from DataGouv API (background job)..."
bundle exec rails runner "DataGouvApiJob.perform_later" &

# Step 5: Run the PoliticianPdfService in the background (it will be triggered by Sidekiq after DataGouvApiJob finishes)
echo "Starting PDF analysis for all politicians (background job)..."
bundle exec rails runner "PoliticianPdfJob.perform_later" &

# Step 6: Run the French encoding cleanup in the background
echo "Starting French encoding cleanup (background job)..."
bundle exec rails runner "FrEncodingCleanupJob.perform_later" &

# Exit the script successfully so Fly.io stops waiting
echo "Release process started successfully. Jobs are running in the background."
exit 0
