RSpec.describe Scraper::Thetrainline::SnapshotFetcher do
  let(:temp_dir) { Dir.mktmpdir }
  let(:from) { "London" }
  let(:to) { "Paris" }
  
  let(:app_config) do
    instance_double(
      "Scraper::Thetrainline::Config",
      fixtures_path: temp_dir
    )
  end

  subject(:fetcher) { described_class.new(from, to, app_config) }

  after { FileUtils.rm_rf(temp_dir) }

  describe "#fetch" do
    context "when snapshot file exists" do
      let(:html_content) { "<html><body>Train schedule</body></html>" }
      
      before do
        File.write(File.join(temp_dir, "london_paris.html"), html_content)
      end

      it "returns the file content" do
        expect(fetcher.fetch).to eq(html_content)
      end
    end

    context "when snapshot file does not exist" do
      it "raises an error with the expected path" do
        expected_path = File.join(temp_dir, "london_paris.html")
        
        expect { fetcher.fetch }
          .to raise_error(RuntimeError, "Fixture not found: #{expected_path}")
      end
    end

    context "with city names containing special characters" do
      let(:from) { "King's Cross" }
      let(:to) { "São Paulo" }
      let(:html_content) { "<html><body>Special route</body></html>" }

      before do
        File.write(File.join(temp_dir, "kings_cross_sao_paulo.html"), html_content)
      end

      it "slugifies city names correctly" do
        expect(fetcher.fetch).to eq(html_content)
      end
    end

    context "with city names containing accents" do
      let(:from) { "München" }
      let(:to) { "Béziers" }
      let(:html_content) { "<html><body>Accented cities</body></html>" }

      before do
        File.write(File.join(temp_dir, "munchen_beziers.html"), html_content)
      end

      it "removes accents from filenames" do
        expect(fetcher.fetch).to eq(html_content)
      end
    end

    context "with city names containing multiple spaces" do
      let(:from) { "New  York" }
      let(:to) { "Los  Angeles" }
      let(:html_content) { "<html><body>US route</body></html>" }

      before do
        File.write(File.join(temp_dir, "new_york_los_angeles.html"), html_content)
      end

      it "normalizes multiple spaces to single underscores" do
        expect(fetcher.fetch).to eq(html_content)
      end
    end
  end
end