RSpec.describe Scraper::Thetrainline::Models::Fare do
  subject(:fare) do
    described_class.new(
      name: "Standard",
      price_in_cents: 5000,
      currency: "BRL"
    )
  end

  it "initializes with attributes" do
    expect(fare.name).to eq("Standard")
    expect(fare.price_in_cents).to eq(5000)
    expect(fare.currency).to eq("BRL")
  end
end
