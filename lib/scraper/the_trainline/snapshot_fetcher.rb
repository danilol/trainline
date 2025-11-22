# frozen_string_literal: true
require "./lib/scraper/the_trainline/utils.rb"

module Scraper
  class TheTrainline
    class SnapshotFetcher
      attr_reader :from, :to, :app_config

      def initialize(from, to, app_config)
        @from = from
        @to = to
        @app_config = app_config
      end

      def fetch
        unless File.exist?(snapshot_path)
          raise "Fixture not found: #{snapshot_path}"
        end

        File.read(snapshot_path) # return the existing html file content as a string
      end

      private
      def snapshot_path
        File.join(@app_config.fixtures_path, "#{Utils.slugify(from)}_#{Utils.slugify(to)}.html")
      end
    end
  end
end