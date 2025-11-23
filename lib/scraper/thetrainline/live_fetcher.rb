# frozen_string_literal: true
require "./config/capybara.rb"
require "./lib/scraper/thetrainline/hydrate_snaphot.rb"

module Scraper
  module Thetrainline
    class LiveFetcher
      attr_reader :url, :app_config

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
        if session.has_css?('#onetrust-accept-btn-handler', wait: 10)
          session.find('#onetrust-accept-btn-handler').click
        end
      end

      def wait_page_to_load(session)
        # "Solve captcha if needed..."
        sleep 10 # or wait until captcha disappears

        # "Wait for journey list hydration..."
        session.has_css?('[role="tabpanel"]', wait: 20)

        # "Wait for at least one journey row to exist..."
        session.has_css?('[data-test*="journey-row"], [id^="result-row-journey-"]', wait: 20)

        session.has_no_css?('[data-test="loading"]', wait: 15) rescue nil
      end
    end
  end
end