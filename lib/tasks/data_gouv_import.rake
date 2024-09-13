# lib/tasks/data_gouv_import.rake
namespace :data_gouv do
    desc "Gather data from CSV and save to database"
    task gather_data: :environment do
      begin
        service = DataGouvApiService.new
        service.gather_data
        puts "Data successfully gathered and saved."
      rescue => e
        Rails.logger.error "Error during data gathering: #{e.message}"
        puts "Error during data gathering: #{e.message}"
      end
    end
  end
