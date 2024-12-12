# app/services/politician_pdf_service.pdf

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
      handle_missing_data(pdf_url)
      return
    end

    extract_info(pdf_content)
  rescue StandardError => e
    Rails.logger.error "Error fetching or analyzing PDF: #{e.message}"
    handle_missing_data
  end

  private

  def handle_missing_data(pdf_url = nil)
    missing_info_message = "Oulala, c'est flou. Cette information n'est pas disponible dans la base de données de la Haute Autorité pour la Transparence de la Vie Publique (https://www.hatvp.fr/). Pourtant c'est requis par la loi n° 2013-907 du 11 octobre 2013 relative à la transparence de la vie publique. N'hésitez pas à en informer votre élu(e), il s'agit peut-être d'un oubli."
    missing_info_message += " Lien du fichier analysé : #{pdf_url}" if pdf_url
    @politician.update(additional_info: missing_info_message)
  end

  def build_pdf_url
    unless @file_name
      Rails.logger.error "No file name found for #{@politician.first_name} #{@politician.last_name}."
      return nil
    end

    pdf_url = BASE_URL + @file_name
    @politician.update(declaration_link: pdf_url) unless @politician.declaration_link.present?
    pdf_url
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

    # **Improved pattern focusing on € as a key indicator of income**
    # Matches "YYYY : {amount} €" or "{amount} €" with optional spaces and newlines
    text.scan(/(\d{4})?\s*:?\s*([0-9\s,.]+)\s*€/) do |year, amount|
      next if amount.nil? || amount.strip.empty?
      year ||= "Non disponible"
      amount_cleaned = amount.gsub(/[\s,]/, "").strip
      entry = "#{year} : #{amount_cleaned} €"
      entries << entry
    end

    entries
  end
end
