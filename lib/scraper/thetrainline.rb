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
require './lib/scraper/thetrainline/logger.rb'

module Scraper
  # NOTE: This is a namespace for the Thetrainline scraper. 
  # The challenge description calls it "Thetrainline", what I decided to follow.
  # Althoug "TheTrainline" (the_trainline) would be more a Ruby convention, 
  # I decided to follow the challenge description.
  module Thetrainline
    # Global instance
    LOGGER = Scraper::Thetrainline::Logger.new(enabled: APP_CONFIG.logs_enabled)
    
    def self.find(from, to, departure_at, app_config: APP_CONFIG)
      Client.new(from, to, departure_at, app_config).fetch_results
    end
  end
end