# spec/models/fare_spec.rb

RSpec.describe Scraper::Thetrainline::Models::Fare do
  let(:fare) do
    described_class.new(
      name: "Standard",
      price_in_cents: 7500,
      currency: "EUR"
    )
  end

  describe "#initialize" do
    it "assigns attributes correctly" do
      expect(fare.name).to eq("Standard")
      expect(fare.price_in_cents).to eq(7500)
      expect(fare.currency).to eq("EUR")
    end

    it "enforces required keyword arguments" do
      expect {
        described_class.new(price_in_cents: 1000, currency: "GBP")
      }.to raise_error(ArgumentError)
    end
  end
end
