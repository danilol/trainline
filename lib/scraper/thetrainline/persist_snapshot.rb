# frozen_string_literal: true
require "./lib/scraper/thetrainline/utils.rb"

module Scraper
  module Thetrainline
    class PersistSnapshot
      attr_reader :from, :to, :content, :app_config

      def initialize(from, to, content, app_config)
        @from = from
        @to = to
        @content = content
        @app_config = app_config
      end

      def write
        write_snapshot_to_file(@content)
      end

      private

      def write_snapshot_to_file(html)
        begin
          filepath = File.join(app_config.fixtures_path, Utils.filename(@from, @to))
          File.write(filepath, html)

          true
        rescue StandardError => e
          LOGGER.error "[HtmlSnapshot] Failed to store snapshot: #{e.message}"
          nil
        end
      end
    end
  end
end
