RSpec.describe Scraper::Thetrainline::AppConfig do
  describe "default mode" do
    around do |example|
      original = ENV["USE_SAVED_FILE"]
      example.run
      ENV["USE_SAVED_FILE"] = original
    end

    it "defaults to :live when USE_SAVED_FILE is not set" do
      ENV["USE_SAVED_FILE"] = nil
      config = described_class.new
      expect(config.mode).to eq(:live)
      expect(config.live?).to be true
      expect(config.snapshot?).to be false
    end

    it "defaults to :live when USE_SAVED_FILE='false'" do
      ENV["USE_SAVED_FILE"] = "false"
      config = described_class.new
      expect(config.mode).to eq(:live)
    end

    it "defaults to :snapshot when USE_SAVED_FILE='true'" do
      ENV["USE_SAVED_FILE"] = "true"
      config = described_class.new
      expect(config.mode).to eq(:snapshot)
    end
  end

  describe "explicit mode" do
    it "accepts :live" do
      config = described_class.new(mode: :live)
      expect(config.mode).to eq(:live)
      expect(config.live?).to be true
      expect(config.snapshot?).to be false
    end

    it "accepts :snapshot" do
      config = described_class.new(mode: :snapshot)
      expect(config.mode).to eq(:snapshot)
      expect(config.snapshot?).to be true
    end
  end

  describe "invalid mode" do
    it "raises an ArgumentError" do
      expect { described_class.new(mode: :invalid_mode) }
        .to raise_error(ArgumentError, /Invalid mode/)
    end
  end
end
