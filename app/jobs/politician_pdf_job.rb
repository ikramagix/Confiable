class PoliticianPdfJob < ApplicationJob
    queue_as :high_priority

    def perform
      puts "Starting Politician PDF job..."
      Politician.find_each do |politician|
        puts "Processing: #{politician.first_name} #{politician.last_name}"
        begin
          PoliticianPdfService.new(politician).fetch_and_analyze_pdf
        rescue => e
          puts "Error processing #{politician.first_name} #{politician.last_name}: #{e.message}"
        end
      end
      puts "Politician PDF job complete."
      # Chain FrenchEncodingJob
      FrenchEncodingJob.perform_later
    end
end
