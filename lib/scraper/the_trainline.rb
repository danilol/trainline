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
      origin = URI.encode_www_form_component("urn:trainline:generic:loc:7527") # London (Any)
      destination = URI.encode_www_form_component("urn:trainline:generic:loc:4922") # Paris (Any)
      date = URI.encode_www_form_component("2025-11-20")

      session = Capybara::Session.new(:cuprite)

      begin
        url = build_url(origin, destination, date)
        session.visit(url)
        accept_cookies(session)
        wait_page_to_load(session)
      ensure
        session.driver.quit
      end
    end

    def fetch_results_from_fixture
      
    end

    def use_fixture?
      false
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
      sleep 2 # or wait until captcha disappears

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

      def initialize(session)
        @session = session
      end

      def log(msg)
        puts "[Trainline Parser] #{msg}"
      end

      def safe(&block)
        retries = 0
        begin
          yield
        rescue Capybara::Cuprite::ObsoleteNode, Capybara::ElementNotFound
          retries += 1
          log "Retrying due to stale element (#{retries})..."
          retry if retries < 5
          nil
        end
      end

      def wait_for_results
        log "Waiting for initial results to load..."
        @session.has_css?(SELECTOR_ROW, wait: 15)

        log "Waiting for DOM to stabilize..."
        sleep 1.5
      end

      def parse
        log "Starting Trainline live parsing..."

        wait_for_results

        rows = safe { @session.all(SELECTOR_ROW) }
        count = rows.size

        log "Found #{count} journey rows."

        results = []

        (0...count).each do |i|
          log "Parsing row #{i + 1} / #{count}..."
          row = safe { @session.all(SELECTOR_ROW, minimum: i + 1)[i] }
          segment = parse_row(row)

          if segment
            log "✔ Row #{i + 1} parsed successfully."
            results << segment
          else
            log "✖ Row #{i + 1} returned nil (skipped)."
          end
        end

        log "Finished parsing all rows."

        results
      end

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

      def parse_times(row)
        node = safe { row.find(SELECTOR_TIMES, wait: 2, match: :first) }
        return {} unless node

        times = node.all("time")
        return {} if times.size < 2

        {
          departure: DateTime.parse(times[0][:datetime]),
          arrival:   DateTime.parse(times[1][:datetime])
        }
      end

      def compute_duration(dep, arr)
        ((arr - dep) * 24 * 60).to_i
      end

      def parse_changes(row)
        node = safe { row.find(SELECTOR_CHANGES, wait: 1, match: :first) }
        return 0 unless node
        node.text[/\d+/].to_i
      end

      def parse_carriers(row)
        safe { row.all(SELECTOR_CARRIER_LOGO).map { "trainline" } }
      end

      def parse_fares(row)
        log "  → Parsing fares…"
        cards = safe { row.all(SELECTOR_FARE_CARD) }
        return [] unless cards
        cards.map { |card| parse_fare(card) }.compact
      end

      def parse_fare(card)
        price_node = safe { card.find(SELECTOR_FARE_PRICE, match: :first) }
        price_text = price_node&.text.to_s.strip

        {
          name: infer_fare_name(card.text),
          price_in_cents: extract_price_cents(price_text),
          currency: detect_currency(price_text)
        }.compact
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
    end

    class Fixture
      FIXTURE_DIR = File.join(Dir.pwd, 'fixtures')

      attr_reader :from, :to
      def initialize(from, to)
        @from = from.downcase
        @to = to.downcase
      end
      
      # Save a fixture for later use
      def save_fixture(html)
        filepath = File.join(FIXTURE_DIR, "#{from}_#{to}.html")
        File.write(filepath, html)
      end
    end
  end
end