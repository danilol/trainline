module Scraper
  class TheTrainline
    attr_reader :from, :to, :departure_at, :results

    BASE_URL = "https://www.thetrainline.com"

    def initialize(from, to, departure_at)
      @from = from
      @to = to
      @departure_at = departure_at
      @results = []
      setup_capybara
    end

    def self.find(from, to, departure_at)
      puts "From: #{from}"
      puts "To: #{to}"
      puts "Departure At: #{departure_at}"
      scraper = new(from, to, departure_at)
      results = scraper.fetch_results
    end

    def fetch_results
      if use_fixture? 
        fetch_results_from_fixture
      else
        fetch_results_live
      end
    end

    private

    def fetch_results_live
      origin = URI.encode_www_form_component("urn:trainline:generic:loc:182gb") # London (Any)
      destination = URI.encode_www_form_component("urn:trainline:generic:loc:4916") # Paris (Any)
      date = URI.encode_www_form_component("2025-11-20")

      session = Capybara::Session.new(:cuprite)

      begin
        url = build_url(origin, destination, date)
        session.visit(url)
        accept_cookies(session)
        wait_page_to_load(session)
        fixture = Scraper::TheTrainline::Fixture.new("London", "Paris")
        fixture.save_fixture_from_session(session) if save_fixture?
        html = fixture.extract_hydrated_html(session)

        results = Parser.new(html).parse
      ensure
        session.driver.quit
      end
    end

    def fetch_results_from_fixture
      unless File.exist?('fixtures/london_paris.html')
        raise "Fixture not found: #{path}"
      end

      html = File.read('fixtures/london_paris.html')
      
      results =  Scraper::TheTrainline::Parser.new(html).parse        
    end

    def use_fixture?
      true
    end

    def save_fixture?
      true
    end

    def build_url(origin, destination, date)
      "#{BASE_URL}/book/results?origin=#{origin}&destination=#{destination}&outwardDate=#{date}"
    end

    def accept_cookies(session)
      # 1. Wait for and accept cookies (mandatory!)
      if session.has_css?('#onetrust-accept-btn-handler', wait: 10)
        session.find('#onetrust-accept-btn-handler').click
      end
    end

    def wait_page_to_load(session)
      # 2. Wait for CAPTCHA resolution (you do this manually)
      puts "Solve captcha if needed..."
      sleep 10 # or wait until captcha disappears

      # 3. Wait for journey list hydration
      puts "Wait for journey list hydration..."
      session.has_css?('[role="tabpanel"]', wait: 20)

      # 4. Wait for at least one journey row to exist
      puts "Wait for at least one journey row to exist..."
      session.has_css?('[data-test*="journey-row"], [id^="result-row-journey-"]', wait: 20)

      # Let Trainline finish last DOM updates
      session.has_no_css?('[data-test="loading"]', wait: 15) rescue nil
      sleep 1.5
    end

    def setup_capybara
      Capybara.default_driver = :cuprite
      Capybara.default_max_wait_time = 20

      Capybara.register_driver(:cuprite) do |app|
        Capybara::Cuprite::Driver.new(
          app,
          headless: false,
          window_size: [1280, 900],
          timeout: 30,
          process_timeout: 40,
          js_errors: false
        )
      end
    end

    # frozen_string_literal: true
    class Parser
      SELECTOR_ROW           = '[data-test*="journey-row"], [id^="result-row-journey-"]'
      SELECTOR_TIMES         = '[data-test="journey-times"]'
      SELECTOR_CHANGES       = '[data-test="journey-details-link"]'
      SELECTOR_FARE_CARD     = '[data-test$="ticket-container"]'
      SELECTOR_FARE_PRICE    = '[data-test$="ticket-price"]'
      SELECTOR_CARRIER_LOGO  = 'img[alt="carrier logo"]'

      def initialize(source_)
        # Live mode = Capybara session
        if source_.is_a?(Capybara::Session)
          @mode = :live
          @session = source_
        else
          # Fixture mode = String HTML
          @mode = :fixture
          require "nokogiri"
          @doc = Nokogiri::HTML(source_)
        end
      end

      def log(msg)
        puts "[Trainline Parser] #{msg}"
      end

      # ---------------------------------------------------------------------
      # Unified parse API
      # ---------------------------------------------------------------------
      def parse
        log "Starting parsing in #{@mode} mode…"

        rows = fetch_rows
        log "Found #{rows.size} journey rows."

        rows.map.with_index do |row, i|
          log "Parsing row #{i + 1} / #{rows.size}..."
          segment = parse_row(row)
          if segment
            log "✔ Row #{i + 1} parsed OK."
            segment
          else
            log "✖ Row #{i + 1} skipped (nil)."
            nil
          end
        end.compact
      end

      # ---------------------------------------------------------------------
      # Row collection
      # ---------------------------------------------------------------------
      def fetch_rows
        if live?
          wait_for_results
          safe { @session.all(SELECTOR_ROW) }
        else
          @doc.css(SELECTOR_ROW)
        end
      end

      def wait_for_results
        log "Waiting for rows…"
        @session.has_css?(SELECTOR_ROW, wait: 15)
        sleep 1.0
      end

      # Safe wrapper only needed in live sessions
      def safe(&block)
        return yield unless live?

        retries = 0
        begin
          yield
        rescue Capybara::Cuprite::ObsoleteNode, Capybara::ElementNotFound
          retries += 1
          log "Retry due to stale node (#{retries})"
          retry if retries < 5
          nil
        end
      end

      # ---------------------------------------------------------------------
      # Row parsing
      # ---------------------------------------------------------------------
      def parse_row(row)
        times    = parse_times(row)
        fares    = parse_fares(row)
        changes  = parse_changes(row)
        carriers = parse_carriers(row)

        return nil unless times[:departure] && times[:arrival]

        {
          departure_station: nil,
          departure_at: times[:departure],
          arrival_station: nil,
          arrival_at: times[:arrival],
          service_agencies: carriers,
          duration_in_minutes: compute_duration(times[:departure], times[:arrival]),
          changeovers: changes,
          products: ["train"],
          fares: fares
        }
      end

      # ---------------------------------------------------------------------
      # Times
      # ---------------------------------------------------------------------
      def parse_times(row)
        node = find_node(row, SELECTOR_TIMES)
        return {} unless node

        times =
          if live?
            node.all("time")
          else
            node.css("time")
          end

        return {} if times.size < 2

        dep = extract_datetime(times[0])
        arr = extract_datetime(times[1])

        return {} unless dep && arr

        { departure: dep, arrival: arr }
      end

      def extract_datetime(time_node)
        if live?
          raw = time_node[:datetime]
        else
          raw = time_node["datetime"]
        end
        return nil unless raw
        DateTime.parse(raw)
      end

      # ---------------------------------------------------------------------
      # Changes (e.g. “2 changes”)
      # ---------------------------------------------------------------------
      def parse_changes(row)
        node = find_node(row, SELECTOR_CHANGES)
        return 0 unless node

        text = live? ? node.text : node.text
        text[/\d+/].to_i
      end

      # ---------------------------------------------------------------------
      # Carriers
      # ---------------------------------------------------------------------
      def parse_carriers(row)
        if live?
          safe { row.all(SELECTOR_CARRIER_LOGO).map { "trainline" } }
        else
          row.css(SELECTOR_CARRIER_LOGO).map { "trainline" }
        end
      end

      # ---------------------------------------------------------------------
      # Fares
      # ---------------------------------------------------------------------
      def parse_fares(row)
        log "  → Parsing fares…"

        cards =
          if live?
            safe { row.all(SELECTOR_FARE_CARD) }
          else
            row.css(SELECTOR_FARE_CARD)
          end

        return [] unless cards

        cards.map { |card| parse_fare(card) }.compact
      end

      def parse_fare(card)
        price_node =
          if live?
            safe { card.find(SELECTOR_FARE_PRICE, match: :first) }
          else
            card.at_css(SELECTOR_FARE_PRICE)
          end

        price_text = price_node&.text.to_s.strip

        {
          name: infer_fare_name(card.text),
          price_in_cents: extract_price_cents(price_text),
          currency: detect_currency(price_text)
        }.compact
      end

      # ---------------------------------------------------------------------
      # Shared helpers
      # ---------------------------------------------------------------------
      def compute_duration(dep, arr)
        ((arr - dep) * 24 * 60).to_i
      end

      def infer_fare_name(text)
        t = text.downcase
        return "Standard Class" if t.include?("standard")
        return "First Class" if t.include?("first")
        "Ticket"
      end

      def extract_price_cents(text)
        num = text.gsub(/[^\d.,]/, "").tr(",", ".").to_f
        (num * 100).to_i
      end

      def detect_currency(text)
        return "EUR" if text.include?("€")
        return "GBP" if text.include?("£")
        "EUR"
      end

      # ---------------------------------------------------------------------
      # Unified find method (capybara OR nokogiri)
      # ---------------------------------------------------------------------
      def find_node(row, selector)
        if live?
          safe { row.find(selector, wait: 1, match: :first) }
        else
          row.at_css(selector)
        end
      end

      def live?
        @mode == :live
      end
    end


    class Fixture
      FIXTURE_DIR = File.join(Dir.pwd, 'fixtures')

      attr_reader :from, :to
      def initialize(from, to)
        @from = from.downcase
        @to = to.downcase
      end
      
      # Save a fixture for later use
      def save_fixture_from_session(session)
        puts "[Fixture] Extracting hydrated DOM…"

        html = extract_hydrated_html(session)
        filepath = File.join(FIXTURE_DIR, "#{from}_#{to}.html")
        File.write(filepath, html)

        puts "[Fixture] Saved: #{filepath}"
        filepath
      end

      # Extract Shadow DOM hydration into normal HTML so Nokogiri can read it
      def extract_hydrated_html(session)
        puts 'Extracting hydrated DOM…'
        session.evaluate_script(<<~JS)
          (() => {
            const root = document.querySelector("tl-journey-list");

            // If Trainline changed structure or no shadow root exists,
            // fallback to plain HTML so at least we save *something*
            if (!root || !root.shadowRoot) {
              return document.documentElement.outerHTML;
            }

            const shadow = root.shadowRoot;

            // Clone main DOM snapshot
            const clone = document.documentElement.cloneNode(true);

            // Replace the tl-journey-list content with hydrated Shadow DOM
            const placeholder = clone.querySelector("tl-journey-list");
            placeholder.innerHTML = shadow.innerHTML;

            return clone.outerHTML;
          })();
        JS
      end
    end
  end
end