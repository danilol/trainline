RSpec.describe Scraper::TheTrainline::Utils do
  describe '.slugify' do
    it 'lowercases the input' do
      expect(described_class.slugify('München')).to eq('münchen')
    end

    it 'removes accents and diacritics' do
      expect(described_class.slugify('Béziers')).to eq('béziers')
    end

    it 'converts spaces to underscores' do
      expect(described_class.slugify('New York')).to eq('new_york')
    end

    it 'handles multiple spaces' do
      expect(described_class.slugify('Los  Angeles')).to eq('los__angeles')
    end

    it 'removes special characters' do
      expect(described_class.slugify("King's Cross")).to eq('king\'s_cross')
    end

    it 'handles empty strings' do
      expect(described_class.slugify('')).to eq('')
    end
  end
end