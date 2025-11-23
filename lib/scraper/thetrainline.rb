# frozen_string_literal: true

require 'date' 
require "./config/app_config.rb"
require './lib/scraper/thetrainline/client.rb'

require './lib/scraper/thetrainline/persist_snapshot.rb'
require './lib/scraper/thetrainline/snapshot_fetcher.rb'
require './lib/scraper/thetrainline/live_fetcher.rb'
require './lib/scraper/thetrainline/url_builder.rb'
require './lib/scraper/thetrainline/models/segment.rb'
require './lib/scraper/thetrainline/models/fare.rb'

module Scraper
  module Thetrainline
    def self.find(from, to, departure_at, app_config: Scraper::Thetrainline::AppConfig.new)
      Client.new(from, to, departure_at, app_config).fetch_results
    end
  end
end