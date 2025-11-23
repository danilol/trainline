# frozen_string_literal: true

require 'date' 
require './lib/scraper/thetrainline/parser.rb'

module Scraper
  module Thetrainline
    class Client
      attr_reader :from, :to, :departure_at, :results, :app_config

      def initialize(from, to, departure_at, app_config)
        @from = from
        @to = to
        @departure_at = departure_at
        @results = []
        @app_config = app_config
      end

      def self.find(from, to, departure_at, app_config: Scraper::Thetrainline::AppConfig.new)
        new(from, to, departure_at, app_config).fetch_results
      end

      def fetch_results
        html = fetcher.fetch
        @results = Scraper::Thetrainline::Parser.parse(html)
      end

      private

      def fetcher
        if @app_config.snapshot?
          Scraper::Thetrainline::SnapshotFetcher.new(@from, @to, @app_config)
        else
          url = Scraper::Thetrainline::UrlBuilder.new(@from, @to, @departure_at).build
          Scraper::Thetrainline::LiveFetcher.new(url, app_config)
        end
      end

      def persist_snapshot(html)
        Scraper::Thetrainline::PersistSnapshot.new(html, app_config).write(html)
      end
    end
  end
end