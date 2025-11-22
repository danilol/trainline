# frozen_string_literal: true

module Scraper
  class TheTrainline
    class AppConfig
      VALID_MODES = %i[live snapshot].freeze

      attr_reader :mode

      def initialize(mode: default_mode)
        @mode = normalize_mode(mode)
      end

      def snapshot?
        @mode == :snapshot
      end

      def live?
        @mode == :live
      end

      def fixtures_path
        'fixtures/'
      end

      private

      def default_mode
        ENV.fetch("SNAPSHOT", "false") == "true" ? :snapshot : :live
      end

      def normalize_mode(value)
        sym = value.to_sym
        unless VALID_MODES.include?(sym)
          raise ArgumentError, "Invalid mode: #{value.inspect}"
        end
        sym
      end
    end
  end
end
