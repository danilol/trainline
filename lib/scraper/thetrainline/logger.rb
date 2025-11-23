# frozen_string_literal: true

module Scraper
  module Thetrainline
    class Logger

      def initialize(enabled: true)
        @enabled = enabled
      end

      def info(msg)
        puts "[INFO] #{msg}" if @enabled
      end

      def warn(msg)
        puts "[WARN] #{msg}" if @enabled
      end

      def error(msg)
        puts "[ERROR] #{msg}" if @enabled
      end
    end
  end
end