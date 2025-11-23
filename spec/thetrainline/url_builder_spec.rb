RSpec.describe Scraper::Thetrainline::UrlBuilder do
  let(:origin)       { "London" }
  let(:destination)  { "Paris" }
  let(:date)         { DateTime.new(2025, 1, 1, 12, 0, 0) }

  let(:origin_urn)      { "123origin" }
  let(:destination_urn) { "456destination" }

  before do
    allow(Scraper::Thetrainline::UrnLocator).to receive(:find_urn).with("London").and_return(origin_urn)
    allow(Scraper::Thetrainline::UrnLocator).to receive(:find_urn).with("Paris").and_return(destination_urn)
  end

  describe "#build" do
    it "builds the correct Trainline URL with encoded parameters" do
      url = described_class.new(origin, destination, date).build

      expect(url).to eq(
        "https://www.thetrainline.com/book/results" \
        "?origin=#{URI.encode_www_form_component(origin_urn)}" \
        "&destination=#{URI.encode_www_form_component(destination_urn)}" \
        "&outwardDate=#{URI.encode_www_form_component(date.to_s)}"
      )
    end

    it "encodes speial characters in URNs" do
      allow(Scraper::Thetrainline::UrnLocator).to receive(:find_urn).with("London").and_return("LON A&B")

      url = described_class.new("London", destination, date).build

      expect(url).to include("origin=#{URI.encode_www_form_component("LON A&B")}")
    end

    it "calls locator for both origin and destination" do
      described_class.new(origin, destination, date).build

      expect(Scraper::Thetrainline::UrnLocator).to have_received(:find_urn).with("London")
      expect(Scraper::Thetrainline::UrnLocator).to have_received(:find_urn).with("Paris")
    end

    it "returns a string" do
      url = described_class.new(origin, destination, date).build
      expect(url).to be_a(String)
    end
  end
end
