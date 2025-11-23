# frozen_string_literal: true

module Scraper
  module Thetrainline
    class HydrateSnapshot
      attr_reader :content, :app_config

      def initialize(content, app_config)
        @content = content
        @app_config = app_config
      end

      def run
        build_hydrated_snapshot(content, app_config)
      end

      private

      # Extracts the hydrated DOM from the snapshot so that it can be parsed
      def build_hydrated_snapshot(content, app_config)
        content.evaluate_script(<<~JS)
          (() => {
            const root = document.querySelector("tl-journey-list");

            if (!root || !root.shadowRoot) {
              return document.documentElement.outerHTML;
            }

            const shadow = root.shadowRoot;

            const clone = document.documentElement.cloneNode(true);

            const placeholder = clone.querySelector("tl-journey-list");
            placeholder.innerHTML = shadow.innerHTML;

            return clone.outerHTML;
          })();
        JS
      end
    end
  end
end
