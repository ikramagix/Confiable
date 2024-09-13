# app/services/politician_pdf_service.rb
require 'open-uri'
require 'pdf-reader'

class PoliticianPdfService
  BASE_URL = 'https://www.hatvp.fr/livraison/dossiers/'.freeze

  def initialize(politician)
    @politician = politician
    @file_name = fetch_file_name
  end

  def fetch_and_analyze_pdf
    Rails.logger.info "Starting fetch and analyze process for #{@politician.first_name} #{@politician.last_name}."

    if @politician.assets.present? && @politician.additional_info.present?
      Rails.logger.info "Data already available for #{@politician.first_name} #{@politician.last_name}. Skipping fetch."
      return
    end

    unless @file_name
      handle_missing_data
      return
    end

    pdf_url = build_pdf_url
    unless pdf_url
      Rails.logger.error "Failed to build PDF URL for #{@politician.first_name} #{@politician.last_name}."
      handle_missing_data
      return
    end

    pdf_content = download_pdf(pdf_url)
    unless pdf_content
      Rails.logger.error "Failed to download PDF for #{@politician.first_name} #{@politician.last_name}."
      handle_missing_data
      return
    end

    extract_info(pdf_content)
  rescue StandardError => e
    Rails.logger.error "Error fetching or analyzing PDF: #{e.message}"
    handle_missing_data
  end

  private

  def handle_missing_data
    # Message in French explaining that the data is missing and suggesting to inform the elected official
    missing_info_message = "Oulala, c'est flou. Cette information n'est pas disponible dans la base de données de la Haute Autorité pour la Transparence de la Vie Publique (https://www.hatvp.fr/). Pourtant c'est requis par la loi n° 2013-907 du 11 octobre 2013 relative à la transparence de la vie publique. N'hésitez pas à en informer votre élu(e), il s'agit peut-être d'un oubli."

    @politician.update(additional_info: missing_info_message)
  end

  def build_pdf_url
    if @file_name.nil?
      Rails.logger.error "File name is missing for politician #{@politician.first_name} #{@politician.last_name}. Cannot build URL."
      return nil
    end

    unless @politician.declaration_link.present?
      Rails.logger.info "Setting declaration link for #{@politician.first_name} #{@politician.last_name}."
      @politician.update(declaration_link: BASE_URL + @file_name)
    end

    BASE_URL + @file_name
  end

  def fetch_file_name
    Rails.logger.info "Fetching file name from CSV for #{@politician.first_name} #{@politician.last_name}."

    csv_path = Rails.root.join('public', 'liste.csv')
    csv_data = CSV.read(csv_path, headers: true, col_sep: ';')

    if csv_data.empty?
      Rails.logger.error "CSV file is empty or missing headers."
      return nil
    end

    csv_row = csv_data.find do |row|
      Rails.logger.info "Analyzing row: #{row.inspect}"
      row['nom']&.strip == @politician.last_name.strip && row['prenom']&.strip == @politician.first_name.strip
    end

    if csv_row.nil?
      Rails.logger.error "No matching row found in CSV for #{@politician.first_name} #{@politician.last_name}."
      return nil
    end

    csv_row['nom_fichier']
  end

  def download_pdf(url)
    Rails.logger.info "Attempting to download PDF from #{url}."
    URI.open(url)
  rescue OpenURI::HTTPError => e
    Rails.logger.error "Failed to download PDF from #{url}: #{e.message}"
    nil
  end

  def extract_info(pdf_content)
    Rails.logger.info "Extracting information from PDF content."
    reader = PDF::Reader.new(pdf_content)
    text = reader.pages.map(&:text).join("\n")

    if text.blank?
      Rails.logger.error("Failed to extract text from PDF.")
      handle_missing_data
      return
    end

    Rails.logger.info("Extracted text from PDF successfully.")
    declared_income, total_income = extract_declared_income(text)
    comments = extract_comments(text)

    Rails.logger.info("Saving extracted data to the database for #{@politician.first_name} #{@politician.last_name}.")
    @politician.update(assets: declared_income.to_json, additional_info: comments)
  end
  def extract_declared_income(text)
    Rails.logger.info "Starting to extract declared income information."
    income_data = {}
    total_income = 0
  
    # Extract all relevant sections using a flexible pattern that captures each section as a block
    income_sections = text.scan(/(\d+°.*?)(?=\d+°|\z)/m)
  
    if income_sections.empty?
      Rails.logger.info("No income sections found in the PDF.")
      return [{}, 0]
    end
  
    income_sections.each_with_index do |section, index|
      section_text = section.first
      Rails.logger.info("Analyzing section #{index + 1}: #{section_text}")
  
      # Updated regex pattern to capture year-specific income details across lines and sections
      # This pattern is more robust to capture various line formats and spacing issues
      income_matches = section_text.scan(/(?<!\d)(\d{4})\s*:\s*([\d\s,]+)€\s*Net/i)
  
      # Add logging to ensure we know when data is missing or captured
      if income_matches.empty?
        Rails.logger.info("No income data found in section #{index + 1}.")
        next
      end
  
      # Process each year and income pair found in the section
      income_matches.each do |year, income|
        formatted_income = income.gsub(/[^\d]/, '').to_i
        income_data[year] ||= { 'amount' => 0 }
        income_data[year]['amount'] += formatted_income
        total_income += formatted_income
        Rails.logger.info("Found income for #{year}: #{formatted_income} € Net.")
      end
    end
  
    # Add the total income to the hash for display and calculations
    income_data['total_income'] = total_income
    Rails.logger.info("Total declared income: #{total_income} € Net.")
  
    [income_data, total_income]
  end
  
  
  def extract_comments(text)
    Rails.logger.info "Extracting comments from the PDF."
    comments_section = text.scan(/Commentaire\s*:\s*([^\n]+)/i)
    if comments_section.empty?
      Rails.logger.info("No comments found in the PDF.")
      return "Aucun commentaire disponible."
    end

    comments = comments_section.flatten.join(", ")
    Rails.logger.info("Extracted comments: #{comments}.")
    comments
  end
end
