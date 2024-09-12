# app/services/data_gouv_api_service.rb
require 'csv'

class DataGouvApiService
  CSV_PATH = Rails.root.join('public', 'liste.csv') # Path to the local CSV file

  def gather_data(limit = 15)
    csv_data = read_csv(CSV_PATH)
    parse_and_save_data(csv_data, limit)
  rescue StandardError => e
    Rails.logger.error("Error gathering data: #{e.message}")
  end

  private

  def read_csv(path)
    puts "Reading CSV from: #{path}"
    CSV.read(path, headers: true, col_sep: ';') # Using correct delimiter ';'
  rescue Errno::ENOENT => e
    Rails.logger.error("CSV file not found: #{e.message}")
    raise
  rescue CSV::MalformedCSVError => e
    Rails.logger.error("Error reading CSV file: #{e.message}")
    raise
  end

  def parse_and_save_data(csv_data, limit)
    csv_data.first(limit).each do |row|
      cvl = row['civilite']&.strip
      first_name = row['prenom']&.strip
      last_name = row['nom']&.strip
      position = row['qualite']&.strip
      role = row['type_mandat']&.strip # Mapping 'type_mandat' to 'role' in the DB
      department = row['departement']&.strip
      organization = row['organisme']&.strip
      publication_date = row['date_publication']&.strip
      file_name = row['nom_fichier']&.strip # Extract file name

      # Print the file name
      puts "Processing file: #{file_name}"

      # Find or create a politician and update their details
      politician = Politician.find_or_initialize_by(last_name: last_name, first_name: first_name, position: position)
      politician.assign_attributes(
        cvl: cvl,
        role: role, # Correctly setting the 'role' field
        department: department,
        organization: organization,
        publication_date: publication_date
      )

      # Save the politician record
      if politician.save
        Rails.logger.info("Politician #{politician.first_name} #{politician.last_name} saved successfully.")
      else
        Rails.logger.error("Failed to save politician #{politician.first_name} #{politician.last_name}: #{politician.errors.full_messages.join(', ')}")
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error parsing CSV data: #{e.message}")
  end
end
