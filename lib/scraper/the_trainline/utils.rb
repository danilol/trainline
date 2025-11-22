module Scraper
  class TheTrainline
    class Utils 
      # TODO: can be improved to remove special characters
      def self.slugify(name)
        name.downcase.gsub(" ", "_")
      end

      def self.filename(from, to)
        "#{Utils.slugify(from)}_#{Utils.slugify(to)}.html"
      end
    end
  end
end