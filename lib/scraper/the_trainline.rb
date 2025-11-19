# frozen_string_literal: true

require 'date' 
require 'capybara'
require 'capybara/cuprite'
require './lib/scraper/the_trainline/parser.rb'
require './lib/scraper/the_trainline/html_snapshot.rb'
require './lib/scraper/the_trainline/urn_locator.rb'

module Scraper
  class TheTrainline
    attr_reader :from, :to, :departure_at, :results
    attr_accessor :snapshot_mode

    @snapshot_mode = (ENV["SNAPSHOT"] == "true" ? :snapshot : :live)

    BASE_URL = "https://www.thetrainline.com"

    def initialize(from, to, departure_at)
      @from = from
      @to = to
      @departure_at = departure_at
      @results = []
      setup_capybara
    end

    def self.find(from, to, departure_at)
      new(from, to, departure_at).fetch_results
    end

    def fetch_results
      if self.class.use_snapshot?
        fetch_results_from_snapshot
      else
        fetch_results_live
      end
    end

    private

    def fetch_results_live
      origin = URI.encode_www_form_component("urn:trainline:generic:loc:182gb") # London (Any)
      destination = URI.encode_www_form_component("urn:trainline:generic:loc:4916") # Paris (Any)
      date = encode_param(departure_at.to_s)

      session = Capybara::Session.new(:cuprite)

      begin
        url = build_url(origin, destination, date)
        session.visit(url)
        accept_cookies(session)
        wait_page_to_load(session)

        html_snapshot = HtmlSnapshot.new("London", "Paris", false).snapshot(session)
        results = Parser.parse(html_snapshot)
      ensure
        session.driver.quit
      end
    end

    def fetch_results_from_snapshot
      path = 'fixtures/london_paris.html'
      unless File.exist?(path)
        raise "Fixture not found: #{path}"
      end

      html = File.read('fixtures/london_paris.html')
      results = Parser.parse(html)        
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

    def encode_param(param)
      URI.encode_www_form_component(param.to_s)
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

    def self.use_snapshot?
      @snapshot_mode == :snapshot
    end

    def self.use_snapshot=(bool)
      @snapshot_mode = bool ? :snapshot : :live
    end
  end
end