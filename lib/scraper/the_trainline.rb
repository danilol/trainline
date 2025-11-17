module Scraper
  class TheTrainline
    BASE_URL = "https://www.thetrainline.com"
    def self.find(from, to, departure_at)
      puts "From: #{from}"
      puts "To: #{to}"
      puts "Departure At: #{departure_at}"
    end
  end
end