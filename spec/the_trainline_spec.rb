RSpec.describe Scraper::TheTrainline do
  describe '.find' do
    let(:from) { 'London' }
    let(:to)   { 'Paris' }
    let(:departure_at) { DateTime.new(2025, 11, 20, 9, 0, 0) }
    let(:app_config) { Scraper::TheTrainline::AppConfig.new(mode: :snapshot) }

    it 'returns an array of segments' do
      results = described_class.find(from, to, departure_at, app_config: app_config)

      expect(results).to be_an(Array)
      expect(results).not_to be_empty

      first = results.first
      expect(first).to be_a(Hash)

      expect(first).to include(
        :departure_at,
        :arrival_at,
        :service_agencies,
        :duration_in_minutes,
        :changeovers,
        :products,
        :fares
      )

      expect(first[:fares]).to be_an(Array)
      expect(first[:fares]).not_to be_empty

      fare = first[:fares].first
      expect(fare).to include(
        :name,
        :price_in_cents,
        :currency
      )
    end
  end
end