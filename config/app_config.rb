# frozen_string_literal: true

module Scraper
  module Thetrainline
    class AppConfig

      VALID_MODES = %i[live snapshot].freeze

      attr_reader :mode, :headless, :logs_enabled, :create_snapshot_file

      def initialize(mode: default_mode, headless: false, logs_enabled: true, create_snapshot_file: default_create_snapshot_file)
        @mode = normalize_mode(mode)
        @headless = headless
        @logs_enabled = logs_enabled
        @create_snapshot_file = create_snapshot_file
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

      # TODO: HEADLESS not fully functioning. Due to time constraints 
      # and Trainline’s bot protection, it mostly works only in non-headless mode.
      def headless?
        ENV["HEADLESS"] == "true"
      end

      def normalize_mode(value)
        sym = value.to_sym
        unless VALID_MODES.include?(sym)
          raise ArgumentError, "Invalid mode: #{value.inspect}"
        end
        sym
      end

      def default_create_snapshot_file
        ENV.fetch("CREATE_SNAPSHOT_FILE", "false") == "true"
      end
    end
  end
end