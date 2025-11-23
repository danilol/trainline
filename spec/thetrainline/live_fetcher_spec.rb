RSpec.describe Scraper::Thetrainline::LiveFetcher do
  let(:url) { "https://www.thetrainline.com/book/results" }
  let(:app_config) { instance_double("Scraper::Thetrainline::AppConfig") }
  let(:session) { instance_double(Capybara::Session) }
  let(:driver) { instance_double(Capybara::Cuprite::Driver) }
  let(:hydrate_snapshot) { instance_double(Scraper::Thetrainline::HydrateSnapshot) }

  subject(:fetcher) { described_class.new(url, app_config) }

  before do
    allow(Capybara::Session).to receive(:new).with(:cuprite).and_return(session)
    allow(session).to receive(:driver).and_return(driver)
    allow(driver).to receive(:quit)
    allow(session).to receive(:visit)
    allow(session).to receive(:has_css?).and_return(false)
    allow(session).to receive(:has_no_css?).and_return(true)

    allow(Scraper::Thetrainline::HydrateSnapshot).to receive(:new).with(session, app_config).and_return(hydrate_snapshot)
    allow(hydrate_snapshot).to receive(:run).and_return("<html>snapshot</html>")
  end

  describe "#fetch" do
    it "visits the URL" do
      fetcher.fetch
      expect(session).to have_received(:visit).with(url)
    end

    it "returns the hydrated snapshot HTML" do
      result = fetcher.fetch
      expect(result).to eq("<html>snapshot</html>")
    end

    it "always quits the driver" do
      fetcher.fetch
      expect(driver).to have_received(:quit)
    end

    context "when the cookie banner appears" do
      before do
        allow(session).to receive(:has_css?).with('#onetrust-accept-btn-handler', wait: 1).and_return(true)

        cookie_btn = double("CookieBtn", click: true)
        allow(session).to receive(:find).with('#onetrust-accept-btn-handler').and_return(cookie_btn)

        @cookie_btn = cookie_btn
      end

      it "clicks the cookie accept button" do
        fetcher.fetch
        expect(@cookie_btn).to have_received(:click)
      end
    end

    context "when an error occurs" do
      before { allow(session).to receive(:visit).and_raise(StandardError, "Connection failed") }

      it "quits the driver" do
        expect { fetcher.fetch }.to raise_error(StandardError, "Connection failed")
        expect(driver).to have_received(:quit)
      end
    end
  end
end
