RSpec.describe Scraper::TheTrainline::UrnLocator do
  let(:response_body) do
    {
      "searchLocations" => [
        { "code" => "urn:trainline:generic:loc:1000", "name" => "Berlin (Any)" },
        { "code" => "urn:trainline:generic:loc:1001", "name" => "Berlin Hbf" },
        { "code" => "urn:trainline:generic:loc:1002", "name" => "Berlingen" },
        { "code" => "urn:trainline:generic:loc:1002", "name" => "Lisbon", "translatedName" => "Lisboa" }
      ]
    }
  end

  before do
    allow(HTTParty).to receive(:get).and_return(response_body)
  end

  it "returns exact match URN" do
    urn = described_class.find_urn("Berlin (Any)")
    expect(urn).to eq("urn:trainline:generic:loc:1000")
  end

  it "returns prefix match URN" do
    urn = described_class.find_urn("Berlin")
    expect(urn).to eq("urn:trainline:generic:loc:1000")
  end

  it "returns substring match URN" do
    urn = described_class.find_urn("erl")
    expect(urn).to eq("urn:trainline:generic:loc:1000")
  end

  it "returns translated name match URN when exists" do
    urn = described_class.find_urn("lisboa")
    expect(urn).to eq("urn:trainline:generic:loc:1002")
  end

  it "returns first result if no match" do
    urn = described_class.find_urn("nonexistent")
    expect(urn).to eq("urn:trainline:generic:loc:1000")
  end
end
