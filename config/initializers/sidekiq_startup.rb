Sidekiq.configure_server do |config|
    config.on(:startup) do
      Rails.logger.info("Checking if jobs have already been queued...")

      lockfile_path = Rails.root.join("tmp/post_deploy_jobs.lock")

      if !File.exist?(lockfile_path)
        File.open(lockfile_path, "w") do |file|
          file.write(Time.now.to_s)
        end

        Rails.logger.info("Enqueuing DataGouvApiJob")
        DataGouvApiJob.perform_later

        Rails.logger.info("Enqueuing PoliticianPdfJob")
        PoliticianPdfJob.perform_later

        Rails.logger.info("Enqueuing FrEncodingCleanupJob")
        FrEncodingCleanupJob.perform_later
      else
        Rails.logger.info("Jobs were already queued. Skipping...")
      end
    end
  end
