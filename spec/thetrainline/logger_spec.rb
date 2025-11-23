require "stringio"

RSpec.describe Scraper::Thetrainline::Logger do
  let(:output) { StringIO.new }
  let(:logger) { described_class.new(enabled: enabled) }

  before do
    # Redirect STDOUT so we can capture puts output
    @original_stdout = $stdout
    $stdout = output
  end

  after do
    # Restore STDOUT
    $stdout = @original_stdout
  end

  context "when enabled" do
    let(:enabled) { true }

    it "prints info messages" do
      logger.info("hello")
      expect(output.string).to include("[INFO] hello")
    end

    it "prints warn messages" do
      logger.warn("be careful")
      expect(output.string).to include("[WARN] be careful")
    end

    it "prints error messages" do
      logger.error("boom")
      expect(output.string).to include("[ERROR] boom")
    end
  end

  context "when disabled" do
    let(:enabled) { false }

    it "suppresses info messages" do
      logger.info("hello")
      expect(output.string).to eq("")
    end

    it "suppresses warnings" do
      logger.warn("warning!")
      expect(output.string).to eq("")
    end

    it "suppresses errors" do
      logger.error("error!")
      expect(output.string).to eq("")
    end
  end
end
