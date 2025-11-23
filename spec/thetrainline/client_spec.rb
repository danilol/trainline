RSpec.describe Scraper::Thetrainline do
  describe ".find" do
    let(:from)         { "London" }
    let(:to)           { "Paris" }
    let(:departure_at) { DateTime.new(2025, 11, 20, 9) }
    let(:app_config)   { instance_double(Scraper::Thetrainline::AppConfig) }
    let(:logger)       { instance_double(Scraper::Thetrainline::Logger) }

    before do
      # override global config for the test
      described_class.app_config = app_config
      described_class.logger     = logger
    end

    it "instantiates a Client and returns its fetch_results value" do
      fake_client = instance_double(Scraper::Thetrainline::Client)
      fake_results = [:fake_segment]

      expect(Scraper::Thetrainline::Client)
        .to receive(:new)
        .with(from, to, departure_at, app_config, logger)
        .and_return(fake_client)

      expect(fake_client)
        .to receive(:fetch_results)
        .and_return(fake_results)

      result = described_class.find(from, to, departure_at)

      expect(result).to eq(fake_results)
    end
  end
end
