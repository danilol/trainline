# frozen_string_literal: true

module Scraper
  module Thetrainline
    class HydrateSnapshot
      attr_reader :driver, :app_config

      def initialize(driver, app_config)
        @driver = driver          # PlaywrightDriver instance
        @page   = driver.page     # Playwright::Page
        @app_config = app_config
      end

      def run
        build_hydrated_snapshot
      end

      private

      # Extracts hydrated HTML including shadow DOM
      def build_hydrated_snapshot
        @page.evaluate(<<~JS)
          () => {
            const root = document.querySelector("tl-journey-list");

            if (!root || !root.shadowRoot) {
              return document.documentElement.outerHTML;
            }

            const shadow = root.shadowRoot;

            const clone = document.documentElement.cloneNode(true);
            const placeholder = clone.querySelector("tl-journey-list");

            if (placeholder) {
              placeholder.innerHTML = shadow.innerHTML;
            }

            return clone.outerHTML;
          }
        JS
      end
    end
  end
end
