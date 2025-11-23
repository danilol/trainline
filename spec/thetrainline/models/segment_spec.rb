# spec/models/segment_spec.rb

RSpec.describe Scraper::Thetrainline::Models::Segment do
  let(:fare) do
    Scraper::Thetrainline::Models::Fare.new(
      name: "Standard",
      price_in_cents: 5000,
      currency: "BRL"
    )
  end

  let(:segment) do
    described_class.new(
      departure_station: "Berlin Hbf",
      departure_at: DateTime.new(2025, 11, 20, 9, 0, 0),
      arrival_station: "Hamburg Hbf",
      arrival_at: DateTime.new(2025, 11, 20, 11, 20, 0),
      service_agencies: ["DB"],
      duration_in_minutes: 140,
      changeovers: 0,
      products: ["train"],
      fares: [fare]
    )
  end

  describe "#initialize" do
    it "assigns all attributes" do
      expect(segment.departure_station).to eq("Berlin Hbf")
      expect(segment.arrival_station).to eq("Hamburg Hbf")
      expect(segment.departure_at).to be_a(DateTime)
      expect(segment.arrival_at).to be_a(DateTime)
      expect(segment.service_agencies).to eq(["DB"])
      expect(segment.duration_in_minutes).to eq(140)
      expect(segment.changeovers).to eq(0)
      expect(segment.products).to eq(["train"])
      expect(segment.fares).to eq([fare])
    end

    it "allows default values" do
      seg = described_class.new(
        departure_station: "A",
        departure_at: DateTime.now,
        arrival_station: "B",
        arrival_at: DateTime.now
      )

      expect(seg.service_agencies).to eq([])
      expect(seg.duration_in_minutes).to eq(0)
      expect(seg.changeovers).to eq(0)
      expect(seg.products).to eq([])
      expect(seg.fares).to eq([])
    end
  end
end
