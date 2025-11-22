RSpec.describe Scraper::TheTrainline::PersistSnapshot do
  let(:html_content) { "<html><body>snapshot</body></html>" }
  let(:temp_dir) { Dir.mktmpdir }
  let(:from) { "London" }
  let(:to) { "Paris" }
  
  let(:app_config) do
    instance_double("Scraper::TheTrainline::Config", fixtures_path: temp_dir)
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

    it "returns nil and logs error when writing fails" do
      allow(File).to receive(:write).and_raise(StandardError, "disk full")
      
      expect { persist.write }
        .to output(/Failed to store snapshot: disk full/).to_stdout
      
      expect(persist.write).to be_nil
    end

    context "with special characters in route names" do
      let(:from) { "München" }
      let(:to) { "Béziers" }

      it "creates a valid filename" do
        persist.write
        files = Dir.glob(File.join(temp_dir, "münchen_béziers.html"))
        expect(files).not_to be_empty
      end
    end
  end
end