# frozen_string_literal: true

require "nokogiri"
require "date"
require "scraper/thetrainline/parser"
require "scraper/thetrainline/models/segment"
require "scraper/thetrainline/models/fare"

RSpec.describe Scraper::Thetrainline::Parser do
  let(:logger) { instance_double(Scraper::Thetrainline::Logger, info: nil) }

  describe ".parse" do
    let(:html) do
      <<~HTML
        <div data-test="cjs-container">
          <div class="_8ro498" aria-label="Departs from Hamburg Hbf at 05:50." data-test="station-name">Hamburg Hbf</div>
          <div class="_8ro498" aria-label="Arrives at Berlin Hbf (tief) at 08:20." data-test="station-name">Berlin Hbf</div>
        </div>

        <div data-test="journey-row">
          <div data-test="journey-times">
            <time datetime="2025-01-01T10:00"></time>
            <time datetime="2025-01-01T11:30"></time>
          </div>

          <div data-test="journey-details-link">1 change</div>

          <div data-test="sample-ticket-container">
            <span data-test="sample-ticket-price">€20.00</span>
          </div>

          <img alt="carrier logo" />
        </div>
      HTML
    end

    it "parses full HTML into an array of Segment objects" do
      allow(logger).to receive(:info)

      results = described_class.parse(html, logger)

      expect(results).to be_an(Array)
      expect(results.size).to eq(1)

      segment = results.first
      expect(segment).to be_a(Scraper::Thetrainline::Models::Segment)

      expect(segment.departure_station).to eq("Hamburg Hbf")
      expect(segment.arrival_station).to eq("Berlin Hbf")

      expect(segment.departure_at).to be_a(DateTime)
      expect(segment.arrival_at).to be_a(DateTime)

      expect(segment.duration_in_minutes).to eq(90)
      expect(segment.changeovers).to eq(1)
      expect(segment.service_agencies).to eq(["trainline"])

      expect(segment.fares.first.price_in_cents).to eq(2000)

      expect(logger).to have_received(:info).with(/Parsing row 1/)
    end
  end

  #
  # -------------------------------------------------------------------
  #  UNIT TEST — .parse_row
  # -------------------------------------------------------------------
  #

  describe ".parse_row" do
    let(:stations) do
      { departure_station: "Madrid", arrival_station: "Barcelona" }
    end

    let(:row_html) do
      <<~HTML
        <div data-test="journey-row">
          <div data-test="journey-times">
            <time datetime="2025-01-01T08:00"></time>
            <time datetime="2025-01-01T10:45"></time>
          </div>

          <div data-test="journey-details-link">0 changes</div>

          <div data-test="abc-ticket-container">
            <span data-test="abc-ticket-price">€12.50</span>
          </div>

          <img alt="carrier logo" />
        </div>
      HTML
    end

    let(:row_node) { Nokogiri::HTML(row_html) }

    it "builds a Segment from a single row" do
      segment = described_class.parse_row(row_node, stations)

      expect(segment.departure_station).to eq("Madrid")
      expect(segment.arrival_station).to eq("Barcelona")
      expect(segment.duration_in_minutes).to eq(165)
      expect(segment.service_agencies).to eq(["trainline"])
      expect(segment.fares.first.price_in_cents).to eq(1250)
    end

    it "returns nil if times are missing" do
      row = Nokogiri::HTML('<div data-test="journey-row"></div>')
      expect(described_class.parse_row(row, stations)).to be_nil
    end
  end
end
