class DataGouvApiJob < ApplicationJob
    queue_as :high_priority

    def perform
      puts "Starting DataGouv API job..."
      DataGouvApiService.new.gather_data
      puts "DataGouv API job complete."
      # Chain PoliticianPdfJob
      PoliticianPdfJob.perform_later
    end
end
