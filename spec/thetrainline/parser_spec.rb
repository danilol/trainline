RSpec.describe Scraper::Thetrainline::Parser do
  let(:html_content) { fixture("london_paris.html") }

  it 'parses the fixture into structured segments' do
    results = described_class.parse(html_content)

    expect(results).to be_an(Array)
    expect(results).not_to be_empty

    segment = results.first
    expect(segment.departure_at).to be_a(DateTime)
    expect(segment.arrival_at).to be_a(DateTime)
    expect(segment.duration_in_minutes).to be_an(Integer)
    expect(segment.service_agencies).to all(be_a(String))
  end
end