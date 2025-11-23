# frozen_string_literal: true

require 'date' 
require './lib/scraper/thetrainline/parser.rb'

module Scraper
  module Thetrainline
    class Client
      attr_reader :from, :to, :departure_at, :results, :app_config, :logger

      def initialize(from, to, departure_at, app_config, logger)
        @from = from
        @to = to
        @departure_at = departure_at
        @results = []
        @app_config = app_config
        @logger = logger
      end

      def self.find(from, to, departure_at, app_config: Scraper::Thetrainline::AppConfig.new)
        new(from, to, departure_at, app_config).fetch_results
      end

      def fetch_results
        html = fetcher.fetch
        @results = Scraper::Thetrainline::Parser.parse(html, @logger)
      end

      private

      def fetcher
        if @app_config.snapshot?
          Scraper::Thetrainline::SnapshotFetcher.new(@from, @to, @app_config)
        else
          url = Scraper::Thetrainline::UrlBuilder.new(@from, @to, @departure_at, @logger).build
          content = Scraper::Thetrainline::LiveFetcher.new(url, @app_config)
          create_snapshot_file(content) if @app_config.create_snapshot_file
          content
        end
      end

      def create_snapshot_file(html)
        Scraper::Thetrainline::PersistSnapshot.new(@from, @to, html, @app_config, @logger).write
      end
    end
  end
end