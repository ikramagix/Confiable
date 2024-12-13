#!/bin/bash 

# Step 1: Database tasks
echo "Dropping existing database..."
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:drop

echo "Creating database..."
bundle exec rails db:create

echo "Running migrations..."
bundle exec rails db:migrate

# Exit immediately (all jobs will be handled by Sidekiq)
echo "Release process complete."
exit 0