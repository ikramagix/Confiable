# Prevent this from running during asset precompilation
if !ENV['RAILS_ENV'].eql?('production') || ENV['ASSETS_PRECOMPILE'].to_s.empty?
    Rails.application.config.after_initialize do
      DataGouvApiJob.perform_later
      PoliticianPdfJob.perform_later
      FrEncodingCleanupJob.perform_later
    end
  end  