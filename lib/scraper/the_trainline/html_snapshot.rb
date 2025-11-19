# frozen_string_literal: true

module Scraper
  class TheTrainline
    class HtmlSnapshot
      FIXTURE_DIR = File.join(Dir.pwd, 'fixtures')

      attr_reader :from, :to

      def initialize(from, to, store_snapshot = false)
        @from = from.downcase
        @to = to.downcase
        @store_snapshot = store_snapshot
      end

      def snapshot(session)
        html = build_hydrated_snapshot(session)
        write_snapshot_to_file(html) if @store_snapshot
        html
      end

      private

      def build_hydrated_snapshot(session)
        puts 'Extracting hydrated DOM'
        session.evaluate_script(<<~JS)
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

      def write_snapshot_to_file(html)
        begin
          puts "[HtmlSnapshot] Extracting hydrated DOM"

          filepath = File.join(FIXTURE_DIR, "#{from}_#{to}.html")
          File.write(filepath, html)

          puts "[HtmlSnapshot] Saved: #{filepath}"
          true
        rescue StandardError => e
          puts "[HtmlSnapshot] Failed to store snapshot: #{e.message}"
          nil
        end
      end
    end
  end
end
