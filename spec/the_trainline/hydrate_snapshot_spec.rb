RSpec.describe Scraper::TheTrainline::HydrateSnapshot do
  let(:session) { instance_double("Capybara::Session") }
  let(:app_config) { instance_double("Scraper::TheTrainline::Config") }
  let(:hydrated_html) { "<html><body>hydrated</body></html>" }

  subject(:hydrator) { described_class.new(session, app_config) }

  describe "#run" do
    it "returns the evaluated hydrated snapshot" do
      allow(session).to receive(:evaluate_script).and_return(hydrated_html)

      expect(hydrator.run).to eq(hydrated_html)
    end

    it "invokes evaluate_script with JS hydration code" do
      expect(session).to receive(:evaluate_script).with(kind_of(String))

      hydrator.run
    end
  end

  describe "#build_hydrated_snapshot" do
    it "delegates to evaluate_script with the hydration JS" do
      expect(session).to receive(:evaluate_script).with(kind_of(String))

      hydrator.send(:build_hydrated_snapshot, session, app_config)
    end

    it "returns evaluated script result" do
      allow(session).to receive(:evaluate_script).and_return(hydrated_html)

      result = hydrator.send(:build_hydrated_snapshot, session, app_config)
      expect(result).to eq(hydrated_html)
    end
  end
end
