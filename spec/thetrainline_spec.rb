RSpec.describe Scraper::Thetrainline do
  describe ".find" do
    let(:from)         { "London" }
    let(:to)           { "Paris" }
    let(:departure_at) { DateTime.new(2025, 11, 20, 9) }

    let(:fake_config) do
      Scraper::Thetrainline::AppConfig.new(
        mode: :snapshot,
        logs_enabled: false
      )
    end

    let(:fake_logger) { Scraper::Thetrainline::Logger.new(enabled: false) }

    before do
      # Replace global config for the duration of this test
      Scraper::Thetrainline.app_config = fake_config
      Scraper::Thetrainline.logger     = fake_logger
    end

    it "returns an array of Segments from snapshot fixtures" do
      results = described_class.find(from, to, departure_at)

      expect(results).to be_an(Array)
      expect(results).not_to be_empty

      segment = results.first
      expect(segment).to be_a(Scraper::Thetrainline::Models::Segment)

      expect(segment.departure_station).not_to be_nil
      expect(segment.arrival_station).not_to be_nil

      expect(segment.fares).to be_an(Array)
      expect(segment.fares).not_to be_empty

      fare = segment.fares.first
      expect(fare).to be_a(Scraper::Thetrainline::Models::Fare)
      expect(fare.name).not_to be_nil
    end
  end
end
