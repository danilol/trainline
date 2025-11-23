RSpec.describe Scraper::Thetrainline::Utils do
  describe '.slugify' do
    it 'lowercases the input' do
      expect(described_class.slugify('München')).to eq('munchen')
    end

    it 'removes accents and diacritics' do
      expect(described_class.slugify('Béziers')).to eq('beziers')
    end

    it 'converts spaces to underscores' do
      expect(described_class.slugify('New York')).to eq('new_york')
    end

    it 'handles multiple spaces' do
      expect(described_class.slugify('Los  Angeles')).to eq('los_angeles')
    end

    it 'removes special characters' do
      expect(described_class.slugify("King's Cross")).to eq('kings_cross')
    end

    it 'handles empty strings' do
      expect(described_class.slugify('')).to eq('')
    end
  end

  describe '.filename' do
    it 'returns the correct filename' do
      expect(described_class.filename('New York', 'Los Angeles')).to eq('new_york_los_angeles.html')
    end

    it 'returns the correct filename' do
      expect(described_class.filename('King\'s Cross', 'Béziers')).to eq("kings_cross_beziers.html")
    end
  end
end