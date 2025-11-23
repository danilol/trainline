# frozen_string_literal: true
require "./config/capybara.rb"
require "./lib/scraper/thetrainline/hydrate_snapshot.rb"

module Scraper
  module Thetrainline
    class LiveFetcher
      attr_reader :url, :app_config
      # TODO: Make timeout configurable 
      TIMEOUT = 10

      def initialize(url, app_config)
        @url = url
        @app_config = app_config
      end

      def fetch
        session = Capybara::Session.new(:cuprite)

        begin
          session.visit(@url)
          accept_cookies(session)
          wait_page_to_load(session)
          Scraper::Thetrainline::HydrateSnapshot.new(session, @app_config).run
        ensure
          session.driver.quit
        end
      end

      private

      def accept_cookies(session)
        if session.has_css?('#onetrust-accept-btn-handler', wait: 1)
          session.find('#onetrust-accept-btn-handler').click
        end
      end

      def wait_page_to_load(session)
        # manually solve captcha if needed...
        # TODO: Remove the sleep when automatically captcha solving is implemented
        sleep TIMEOUT

        session.has_css?('[role="tabpanel"]', wait: TIMEOUT)

        session.has_css?('[data-test*="journey-row"], [id^="result-row-journey-"]', wait: TIMEOUT)

        session.has_no_css?('[data-test="loading"]', wait: TIMEOUT) rescue nil
      end
    end
  end
end