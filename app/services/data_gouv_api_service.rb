# app/services/data_gouv_api_service.rb
require "roo"

class DataGouvApiService
  XLSX_PATH = Rails.root.join("public", "liste.xlsx")

  def gather_data
    xlsx_data = read_xlsx(XLSX_PATH)
    parse_and_save_data(xlsx_data)
  rescue StandardError => e
    Rails.logger.error("Error gathering data: #{e.message}")
  end

  private

  def read_xlsx(path)
    puts "Reading XLSX from: #{path}"
    sheet = Roo::Excelx.new(path)
    headers = sheet.row(1)
    data = []

    (2..sheet.last_row).each do |i|
      row_data = Hash[headers.zip(sheet.row(i))]
      data << row_data
    end

    data
  rescue Errno::ENOENT => e
    Rails.logger.error("XLSX file not found: #{e.message}")
    raise
  rescue StandardError => e
    Rails.logger.error("Error reading XLSX file: #{e.message}")
    raise
  end

  def parse_and_save_data(xlsx_data)
    xlsx_data.each do |row|
      cvl = row["civilite"].nil? ? "N/A" : row["civilite"].to_s.strip
      first_name = row["prenom"].nil? ? "N/A" : row["prenom"].to_s.strip
      last_name = row["nom"].nil? ? "N/A" : row["nom"].to_s.strip
      position = row["qualite"].nil? ? "N/A" : row["qualite"].to_s.strip
      role = row["type_mandat"].nil? ? "N/A" : row["type_mandat"].to_s.strip
      department = row["departement"].nil? ? "N/A" : row["departement"].to_s.strip
      organization = row["organisme"].nil? ? "N/A" : row["organisme"].to_s.strip
      publication_date = row["date_publication"].nil? ? "N/A" : row["date_publication"].to_s.strip
      file_name = row["nom_fichier"].nil? ? "N/A" : row["nom_fichier"].to_s.strip

      # Print the file name
      puts "Processing file: #{file_name}"

      # Find or create a politician and update their details
      politician = Politician.find_or_initialize_by(last_name: last_name, first_name: first_name, position: position)
      politician.assign_attributes(
        cvl: cvl,
        role: role,
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
    Rails.logger.error("Error parsing XLSX data: #{e.message}")
  end
end
