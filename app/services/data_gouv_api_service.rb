=begin 

NEXT STEP: GATHER TOTAL DATA FOR SCHEDULING LATER A DAILY SCHEDULED TASK AFTER TEST

# app/services/data_gouv_api_service.rb
require 'nokogiri'
require 'open-uri'

class DataGouvApiService
  URL = 'https://www.hatvp.fr/livraison/merge/declarations.xml'

  def fetch_and_save_declarations
    xml_data = URI.open(URL).read
    parse_and_save_declarations(xml_data)
  end

  private

  def parse_and_save_declarations(xml_data)
    document = Nokogiri::XML(xml_data)

    document.xpath('//declaration').each do |declaration_node|
      # Extracting data from XML nodes
      last_name = declaration_node.at_xpath('nom')&.text
      first_name = declaration_node.at_xpath('prenom')&.text
      birth_date = declaration_node.at_xpath('dateNaissance')&.text
      role = declaration_node.at_xpath('fonction')&.text
      organization = declaration_node.at_xpath('organisme')&.text
      publication_date = declaration_node.at_xpath('datePublication')&.text
      location = declaration_node.at_xpath('localisation')&.text
      declaration_link = declaration_node.at_xpath('url')&.text
      assets = declaration_node.at_xpath('patrimoine')&.text
      additional_info = declaration_node.at_xpath('autres_informations')&.text

      # Find or create politician based on name and role
      politician = Politician.find_or_initialize_by(last_name: last_name, first_name: first_name, role: role)

      # Update attributes with the parsed data
      politician.update(
        birth_date: birth_date,
        organization: organization,
        publication_date: publication_date,
        location: location,
        declaration_link: declaration_link,
        assets: assets,
        additional_info: additional_info
      )

      # Save or update the politician record
      if politician.save
        Rails.logger.info("Politician #{politician.first_name} #{politician.last_name} saved successfully.")
      else
        Rails.logger.error("Failed to save politician #{politician.first_name} #{politician.last_name}: #{politician.errors.full_messages.join(', ')}")
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error parsing declarations: #{e.message}")
  end
end
=end

# app/services/data_gouv_api_service.rb
require 'nokogiri'
require 'open-uri'

class DataGouvApiService
  URL = 'https://www.hatvp.fr/livraison/merge/declarations.xml'

  def fetch_and_save_declarations(limit = 15)
    xml_data = URI.open(URL).read
    parse_and_save_declarations(xml_data, limit)
  end

  private

  def parse_and_save_declarations(xml_data, limit)
    document = Nokogiri::XML(xml_data)

    # Process only the first 15 records
    document.xpath('//declaration').first(limit).each do |declaration_node|
      # Extracting data from XML nodes
      last_name = declaration_node.at_xpath('nom')&.text
      first_name = declaration_node.at_xpath('prenom')&.text
      birth_date = declaration_node.at_xpath('dateNaissance')&.text
      role = declaration_node.at_xpath('fonction')&.text
      organization = declaration_node.at_xpath('organisme')&.text
      publication_date = declaration_node.at_xpath('datePublication')&.text
      location = declaration_node.at_xpath('localisation')&.text
      declaration_link = declaration_node.at_xpath('url')&.text
      assets = declaration_node.at_xpath('patrimoine')&.text
      additional_info = declaration_node.at_xpath('autres_informations')&.text

      # Find existing politician or create a new one if it doesn't exist
      politician = Politician.find_or_create_by(last_name: last_name, first_name: first_name, role: role) do |p|
        p.birth_date = birth_date
        p.organization = organization
        p.publication_date = publication_date
        p.location = location
        p.declaration_link = declaration_link
        p.assets = assets
        p.additional_info = additional_info
      end

      # If the politician was found but not updated by `find_or_create_by`, update attributes manually
      if politician.persisted?
        politician.update(
          birth_date: birth_date,
          organization: organization,
          publication_date: publication_date,
          location: location,
          declaration_link: declaration_link,
          assets: assets,
          additional_info: additional_info
        )
      end

      # Log the successful creation or update of the politician
      if politician.save
        Rails.logger.info("Politician #{politician.first_name} #{politician.last_name} saved successfully.")
      else
        Rails.logger.error("Failed to save politician #{politician.first_name} #{politician.last_name}: #{politician.errors.full_messages.join(', ')}")
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error parsing declarations: #{e.message}")
  end
end
