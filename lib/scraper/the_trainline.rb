# frozen_string_literal: true

require 'date' 
require "./config/app_config.rb"
require './lib/scraper/the_trainline/parser.rb'
require './lib/scraper/the_trainline/persist_snapshot.rb'
require './lib/scraper/the_trainline/snapshot_fetcher.rb'
require './lib/scraper/the_trainline/live_fetcher.rb'
require './lib/scraper/the_trainline/url_builder.rb'

module Scraper
  class TheTrainline
    attr_reader :from, :to, :departure_at, :results, :app_config

    def initialize(from, to, departure_at, app_config)
      @from = from
      @to = to
      @departure_at = departure_at
      @results = []
      @app_config = app_config
    end

    def self.find(from, to, departure_at, app_config: Scraper::TheTrainline::AppConfig.new)
      new(from, to, departure_at, app_config).fetch_results
    end

    def fetch_results
      html = fetcher.fetch
      @results = Parser.parse(html)
    end

    private

    def fetcher
      if @app_config.snapshot?
        Scraper::TheTrainline::SnapshotFetcher.new(@from, @to, @app_config)
      else
        url = Scraper::TheTrainline::UrlBuilder.new(@from, @to, @departure_at).build
        Scraper::TheTrainline::LiveFetcher.new(url, app_config)
      end
    end

    def persist_snapshot(html)
      Scraper::TheTrainline::PersistSnapshot.new(html, app_config).write(html)
    end
  end
end