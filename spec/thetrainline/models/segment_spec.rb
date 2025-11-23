RSpec.describe Scraper::Thetrainline::Models::Segment do
  let(:fare) do
    Scraper::Thetrainline::Models::Fare.new(
      name: "Standard",
      price_in_cents: 12345,
      currency: "GBP"
    )
  end

  subject(:segment) do
    described_class.new(
      departure_station: "London",
      departure_at: DateTime.now,
      arrival_station: "Paris",
      arrival_at: DateTime.now + Rational(2, 24),
      service_agencies: ["Eurostar"],
      duration_in_minutes: 120,
      changeovers: 0,
      products: ["train"],
      fares: [fare]
    )
  end

  it "initializes with attributes" do
    expect(segment.departure_station).to eq("London")
    expect(segment.arrival_station).to eq("Paris")
    expect(segment.service_agencies).to eq(["Eurostar"])
    expect(segment.fares).to include(fare)
  end
end
