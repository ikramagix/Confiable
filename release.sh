#!/bin/bash

# Prepare the database
./bin/rails db:prepare

# Check if the previous command was successful
if [ $? -ne 0 ]; then
  echo "Database preparation failed, aborting data gathering."
  exit 1
fi

# Run the data gathering task
rails data_gouv:gather_data

# Check if the data gathering was successful
if [ $? -ne 0 ]; then
  echo "Data gathering failed."
  exit 1
fi

echo "Release script executed successfully."
