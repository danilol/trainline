RSpec.describe Scraper::Thetrainline::LiveFetcher do
  let(:url) { "https://www.thetrainline.com/book/results?origin=123&destination=456" }
  let(:app_config) { instance_double("Scraper::Thetrainline::Config") }
  let(:session) { instance_double(Capybara::Session) }
  let(:driver) { instance_double(Capybara::Cuprite::Driver) }
  let(:hydrate_snapshot) { instance_double(Scraper::Thetrainline::HydrateSnapshot) }

  subject(:fetcher) { described_class.new(url, app_config) }

  before do
    allow(Capybara::Session).to receive(:new).with(:cuprite).and_return(session)
    allow(session).to receive(:driver).and_return(driver)
    allow(driver).to receive(:quit)
  end

  describe "#fetch" do
    before do
      allow(session).to receive(:visit)
      allow(session).to receive(:has_css?).and_return(false)
      allow(session).to receive(:has_no_css?).and_return(true)
      allow(Scraper::Thetrainline::HydrateSnapshot).to receive(:new)
        .with(session, app_config).and_return(hydrate_snapshot)
      allow(hydrate_snapshot).to receive(:run).and_return("<html>snapshot</html>")
    end

    it "visits the URL" do
      fetcher.fetch
      expect(session).to have_received(:visit).with(url)
    end

    it "quits the driver after execution" do
      fetcher.fetch
      expect(driver).to have_received(:quit)
    end

    it "returns the hydrated snapshot" do
      result = fetcher.fetch
      expect(result).to eq("<html>snapshot</html>")
    end

    context "when cookie banner appears" do
      before do
        allow(session).to receive(:has_css?)
          .with('#onetrust-accept-btn-handler', wait: 10).and_return(true)
        allow(session).to receive(:find).with('#onetrust-accept-btn-handler')
          .and_return(double(click: true))
      end

      it "accepts cookies" do
        cookie_button = session.find('#onetrust-accept-btn-handler')
        fetcher.fetch
        expect(cookie_button).to have_received(:click)
      end
    end

    context "when an error occurs" do
      before do
        allow(session).to receive(:visit).and_raise(StandardError, "Connection failed")
      end

      it "still quits the driver" do
        expect { fetcher.fetch }.to raise_error(StandardError, "Connection failed")
        expect(driver).to have_received(:quit)
      end
    end
  end
end