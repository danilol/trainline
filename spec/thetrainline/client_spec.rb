# spec/scraper/thetrainline/client_spec.rb

RSpec.describe Scraper::Thetrainline::Client do
  let(:from)         { 'London' }
  let(:to)           { 'Paris' }
  let(:departure_at) { DateTime.new(2025, 11, 20, 9, 0, 0) }
  let(:app_config)   { Scraper::Thetrainline::AppConfig.new(mode: :snapshot) }

  subject(:client) { described_class.new(from, to, departure_at, app_config) }

  describe '#fetch_results' do
    it 'returns an array of Segment objects' do
      results = client.fetch_results

      expect(results).to be_an(Array)
      expect(results.first).to be_a(Scraper::Thetrainline::Models::Segment)
    end
  end

  describe '.find' do
    it 'delegates to a new client instance' do
      result = described_class.find(from, to, departure_at, app_config: app_config)

      expect(result).to be_an(Array)
    end
  end
end
