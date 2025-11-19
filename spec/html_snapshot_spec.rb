# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "./lib/scraper/the_trainline/html_snapshot"

RSpec.describe Scraper::TheTrainline::HtmlSnapshot do
  let(:from) { "London" }
  let(:to)   { "Paris" }
  let(:session) { instance_double("Capybara::Session") }
  let(:html_content) { "<html><body>mock</body></html>" }

  before do
    allow(session).to receive(:evaluate_script).and_return(html_content)
  end

  describe "#snapshot" do
    context "when store_snapshot is false" do
      subject(:html_snapshot) { described_class.new(from, to, false) }

      it "returns hydrated HTML" do
        expect(html_snapshot.snapshot(session)).to eq(html_content)
      end

      it "does NOT write any file" do
        expect(File).not_to receive(:write)
        html_snapshot.snapshot(session)
      end
    end

    context "when store_snapshot is true" do
      subject(:html_snapshot) { described_class.new(from, to, true) }

      it "writes to a temporary fixture dir instead of real fixtures/" do
        Dir.mktmpdir do |tmp|
          stub_const("#{described_class}::FIXTURE_DIR", tmp)

          html_snapshot.snapshot(session)

          filepath = File.join(tmp, "london_paris.html")
          expect(File.exist?(filepath)).to eq(true)
          expect(File.read(filepath)).to eq(html_content)
        end
      end
    end
  end

  describe "#build_hydrated_snapshot" do
    subject(:html_snapshot) { described_class.new(from, to) }

    it "invokes evaluate_script" do
      expect(session).to receive(:evaluate_script).with(kind_of(String))
      html_snapshot.send(:build_hydrated_snapshot, session)
    end
  end

  describe "#write_snapshot_to_file" do
    subject(:html_snapshot) { described_class.new(from, to) }

    it "writes to temp directory and returns true" do
      Dir.mktmpdir do |tmp|
        stub_const("#{described_class}::FIXTURE_DIR", tmp)

        result = html_snapshot.send(:write_snapshot_to_file, html_content)
        filepath = File.join(tmp, "london_paris.html")

        expect(result).to eq(true)
        expect(File.read(filepath)).to eq(html_content)
      end
    end

    it "returns nil on write failure" do
      allow(File).to receive(:write).and_raise(StandardError.new("disk full"))

      result = html_snapshot.send(:write_snapshot_to_file, html_content)
      expect(result).to eq(nil)
    end
  end
end
