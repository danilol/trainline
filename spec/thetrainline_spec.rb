RSpec.describe Scraper::Thetrainline do
  describe ".find" do
    let(:from)         { "London" }
    let(:to)           { "Paris" }
    let(:departure_at) { DateTime.new(2025, 11, 20, 9) }
    let(:app_config)   { Scraper::Thetrainline::AppConfig.new(mode: :snapshot) }

    it "returns an array of Segments" do
      results = described_class.find(from, to, departure_at, app_config: app_config)

      expect(results).to be_an(Array)
      expect(results).not_to be_empty

      first = results.first
      expect(first).to be_a(Scraper::Thetrainline::Models::Segment)

      expect(first.departure_station).not_to be_nil
      expect(first.arrival_station).not_to be_nil
      expect(first.fares).to be_an(Array)
      expect(first.fares).not_to be_empty

      first_fare = first.fares.first
      expect(first_fare).to be_a(Scraper::Thetrainline::Models::Fare)
      expect(first_fare.name).not_to be_nil
    end
  end
end
