# spec/scraper/thetrainline_spec.rb

RSpec.describe Scraper::Thetrainline do
  describe '.find' do
    let(:from)         { 'London' }
    let(:to)           { 'Paris' }
    let(:departure_at) { DateTime.new(2025, 11, 20, 9, 0, 0) }
    let(:app_config)   { Scraper::Thetrainline::AppConfig.new(mode: :snapshot) }

    it 'returns an array of Segment objects' do
      results = described_class.find(from, to, departure_at, app_config: app_config)

      expect(results).to be_an(Array)
      expect(results).not_to be_empty

      segment = results.first
      expect(segment).to be_a(Scraper::Thetrainline::Models::Segment)

      expect(segment.departure_at).not_to be_nil
      expect(segment.arrival_at).not_to be_nil
      expect(segment.service_agencies).to be_an(Array)
      expect(segment.duration_in_minutes).to be_an(Integer)
      expect(segment.changeovers).to be_an(Integer)
      expect(segment.products).to be_an(Array)
      expect(segment.fares).to be_an(Array)

      fare = segment.fares.first
      expect(fare).to be_a(Scraper::Thetrainline::Models::Fare)
      expect(fare.name).not_to be_nil
      expect(fare.price_in_cents).to be_a(Integer)
      expect(fare.currency).to be_a(String)
    end
  end
end
