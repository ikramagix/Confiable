# app/services/politician_pdf_service.rb
require "open-uri"
require "pdf-reader"

class PoliticianPdfService
  BASE_URL = "https://www.hatvp.fr/livraison/dossiers/".freeze

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
    missing_info_message = "Information not available from the Haute Autorité pour la Transparence de la Vie Publique (https://www.hatvp.fr/). Please inform your representative."
    @politician.update(additional_info: missing_info_message)
  end

  def build_pdf_url
    unless @politician.declaration_link.present?
      @politician.update(declaration_link: BASE_URL + @file_name)
    end
    BASE_URL + @file_name
  end

  def fetch_file_name
    csv_path = Rails.root.join("public", "liste.csv")
    csv_data = CSV.read(csv_path, headers: true, col_sep: ";")
    csv_row = csv_data.find { |row| row["nom"]&.strip == @politician.last_name.strip && row["prenom"]&.strip == @politician.first_name.strip }
    csv_row ? csv_row["nom_fichier"] : nil
  end

  def download_pdf(url)
    URI.open(url)
  rescue OpenURI::HTTPError => e
    Rails.logger.error "Failed to download PDF from #{url}: #{e.message}"
    nil
  end

  def extract_info(pdf_content)
    reader = PDF::Reader.new(pdf_content)
    text = reader.pages.map(&:text).join("\n")

    if text.blank?
      Rails.logger.error("Failed to extract text from PDF.")
      handle_missing_data
      return
    end

    income_entries = extract_income_entries(text)
    @politician.update(assets: income_entries.to_json, additional_info: "Données disponibles trouvées.")
  end

  def extract_income_entries(text)
    entries = []
    text.scan(/(Rémunération|indemnité|gratification)(.*?)(\d{4}\s*:\s*[\d\s,]+€)/im) do |_, _, income|
      entries << income.strip
    end
    entries
  end
end
