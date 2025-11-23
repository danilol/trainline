module Scraper
  module Thetrainline
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
      
      # TODO: Replace this basic logger with a dedicated Logger class.
      def self.log(msg)
        puts "[Trainline Parser] #{msg}"
      end
    end
  end
end