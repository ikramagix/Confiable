Rails.application.config.after_initialize do
    DataGouvApiJob.perform_later
    PoliticianPdfJob.perform_later
    FrEncodingCleanupJob.perform_later
  end
