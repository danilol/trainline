# frozen_string_literal: true

require "./config/app_config"
require "./lib/scraper/thetrainline/client"
require "./lib/scraper/thetrainline/persist_snapshot"
require "./lib/scraper/thetrainline/snapshot_fetcher"
require "./lib/scraper/thetrainline/live_fetcher"
require "./lib/scraper/thetrainline/url_builder"
require "./lib/scraper/thetrainline/models/segment"
require "./lib/scraper/thetrainline/models/fare"
require "./lib/scraper/thetrainline/logger"

module Scraper
  module Thetrainline
    class << self
      attr_accessor :app_config, :logger
    end

    self.app_config = AppConfig.new
    self.logger = Logger.new(enabled: app_config.logs_enabled)

    def self.find(from, to, departure_at)
      Client.new(from, to, departure_at, app_config, logger).fetch_results
    end
  end
end
