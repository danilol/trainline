module Scraper
  class TheTrainline
    class Utils 
      def self.slugify(name)
        name.unicode_normalize(:nfd)
            .gsub(/\p{Mark}/, '')
            .downcase
            .gsub(/[^a-z0-9\s]/, '')
            .gsub(/\s+/, '_')  
      end
      
      def self.filename(from, to)
        "#{Utils.slugify(from)}_#{Utils.slugify(to)}.html"
      end
    end
  end
end