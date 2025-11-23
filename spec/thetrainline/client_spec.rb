RSpec.describe Scraper::Thetrainline::Client do
  let(:from)         { "London" }
  let(:to)           { "Paris" }
  let(:departure_at) { DateTime.new(2025, 11, 20, 9) }
  let(:app_config)   { Scraper::Thetrainline::AppConfig.new(mode: :snapshot) }

  subject(:client) { described_class.new(from, to, departure_at, app_config) }

  describe "#fetch_results" do
    it "returns parsed segments" do
      results = client.fetch_results
      expect(results).to be_an(Array)
      expect(results.first).to be_a(Scraper::Thetrainline::Models::Segment)
    end
  end
end
