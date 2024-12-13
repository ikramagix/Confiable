class FrenchEncodingJob < ApplicationJob
    queue_as :default

    def perform
      puts "Starting French encoding cleanup..."
      require_relative "../../fr_encoding_cleanup"
      puts "French encoding cleanup complete."
    end
end
