# frozen_string_literal: true
require "./config/playwright_driver.rb"
require "./lib/scraper/the_trainline/hydrate_snapshot.rb"
require "./lib/scraper/the_trainline/url_builder.rb"

module Scraper
  class TheTrainline
    class LiveFetcher
      attr_reader :url, :app_config

      def initialize(url, app_config)
        @url = url
        @app_config = app_config
      end

      def fetch
        driver = Scraper::TheTrainline::PlaywrightDriver.new(app_config)

        begin
          driver.visit(url)
          accept_cookies(driver)
          wait_page_to_load(driver)

          # Evaluate JS snapshot hydration
          hydrated_html = driver.evaluate(JS_SNIPPET)
          hydrated_html
        ensure
          driver.close
        end
      end

      private

      # ---------------------------------------------------------------------
      # Playwright-native cookie acceptance
      # ---------------------------------------------------------------------
      def accept_cookies(driver)
        locator = driver.page.locator('#onetrust-accept-btn-handler')

        begin
          locator.wait_for(state: :visible, timeout: 5_000)
          locator.click
        rescue Playwright::TimeoutError
          # Cookie banner didn’t appear → perfectly fine
        end
      end

      # ---------------------------------------------------------------------
      # Proper Playwright load waits
      # ---------------------------------------------------------------------
      def wait_page_to_load(driver)
        page = driver.page

        # Wait until Trainline results container loads
        page.locator('[role="tabpanel"]').wait_for(state: :visible, timeout: 20_000)

        # Wait until at least 1 result row appears
        page.locator('[data-test*="journey-row"], [id^="result-row-journey-"]')
            .first
            .wait_for(state: :visible, timeout: 20_000)
      end
    end
  end
end
