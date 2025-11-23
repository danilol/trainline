require "fileutils"
require "./lib/scraper/thetrainline/persist_snapshot"
require "./lib/scraper/thetrainline/utils"

RSpec.describe Scraper::Thetrainline::PersistSnapshot do
  let(:html_content) { "<html><body>snapshot</body></html>" }
  let(:temp_dir)      { Dir.mktmpdir }
  let(:from)          { "London" }
  let(:to)            { "Paris" }

  let(:app_config) do
    instance_double("Scraper::Thetrainline::AppConfig", fixtures_path: temp_dir)
  end

  subject(:persist) { described_class.new(from, to, html_content, app_config) }

  # Clean up temp directory after each test
  after { FileUtils.rm_rf(temp_dir) }

  describe "#write" do
    it "writes the snapshot file and returns true" do
      expected_path = File.join(temp_dir, "London_Paris.html")

      result = persist.write

      expect(result).to be true
      expect(File).to exist(expected_path)
      expect(File.read(expected_path)).to eq(html_content)
    end

    it "returns nil and logs an error when writing fails" do
      fake_logger = instance_double("Scraper::Thetrainline::Logger", error: nil)
      allow(fake_logger).to receive(:error)

      stub_const("Scraper::Thetrainline::LOGGER", fake_logger)

      allow(File).to receive(:write).and_raise(StandardError, "disk full")

      expect(fake_logger).to receive(:error).with(/\[HtmlSnapshot\] Failed to store snapshot: disk full/)

      result = persist.write
      expect(result).to be_nil
    end

    context "with special characters in route names" do
      let(:from) { "München" }
      let(:to)   { "Béziers" }

      it "creates a valid sanitized filename" do
        persist.write
        files = Dir.glob(File.join(temp_dir, "munchen_beziers.html"))
        expect(files).not_to be_empty
      end
    end
  end
end
