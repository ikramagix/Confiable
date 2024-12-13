# Skip during assets precompilation
if ENV['RAILS_ENV'] != 'assets'
    Rails.logger.info("Enqueuing jobs for Sidekiq")
    DataGouvApiJob.perform_later
    PoliticianPdfJob.perform_later
    FrEncodingCleanupJob.perform_later
  end
  