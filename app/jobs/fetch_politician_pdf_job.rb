# app/jobs/fetch_politician_pdf_job.rb
class FetchPoliticianPdfJob < ApplicationJob
    queue_as :default
  
    def perform(politician_id)
      politician = Politician.find(politician_id)
      # Only fetch data if assets or comments are missing
      unless politician.assets.present? && politician.additional_info.present?
        service = PoliticianPdfService.new(politician)
        service.fetch_and_analyze_pdf
      end
    end
  end
  