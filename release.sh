#!/bin/bash 

# Set up the environment correctly
export PATH="/usr/local/bundle/bin:$PATH"

# Step 1: Drop the database
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

# Step 4: Schedule the DataGouvApiJob (which triggers the others)
echo "Scheduling DataGouvApiJob..."
bundle exec rails runner "DataGouvApiJob.perform_later"
if [ $? -ne 0 ]; then
  echo "Failed to schedule DataGouvApiJob. Aborting release process."
  exit 1
fi

# Step 5: Wait for Sidekiq to process jobs
echo "Waiting for Sidekiq jobs to complete..."
START_TIME=$(date +%s)
MAX_WAIT_TIME=$((12 * 3600)) # 12-hour timeout
SLEEP_INTERVAL=60 # Check status every 60 seconds

while true; do
  # Check Sidekiq queue status
  ACTIVE_JOBS=$(bundle exec rails runner "puts Sidekiq::Queue.new.size + Sidekiq::Workers.new.size + Sidekiq::RetrySet.new.size")
  if [ "$ACTIVE_JOBS" -eq 0 ]; then
    echo "All Sidekiq jobs completed successfully."
    break
  fi

  CURRENT_TIME=$(date +%s)
  ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
  
  if [ "$ELAPSED_TIME" -gt "$MAX_WAIT_TIME" ]; then
    echo "Timeout reached. Some Sidekiq jobs are still running after 12 hours."
    exit 1
  fi
  
  echo "Waiting for jobs to complete. Jobs remaining: $ACTIVE_JOBS. Elapsed time: $((ELAPSED_TIME / 60)) minutes."
  sleep $SLEEP_INTERVAL
done

# Final message
echo "Release process completed successfully."
