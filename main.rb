require './lib/scraper/thetrainline.rb'

require 'debug'

puts 'This is the beginning of the program'

# * The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`

# urn = Scraper::Thetrainline::UrnLocator.find_urn('Londres')
# pp urn
 results = Scraper::Thetrainline.find('London', 'Paris', Date.today + 1)
# results2 = Scraper::Thetrainline.find('Munich', 'Hamburg', Date.today + 1)
# results3 = Scraper::Thetrainline.find('Lisboa', 'Faro', Date.today + 1)
# results4 = Scraper::Thetrainline.find('Paris', 'Marseille', Date.today + 1)
# results5 = Scraper::Thetrainline.find('Roma', 'Venezia', Date.today + 1)
# results6 = Scraper::Thetrainline.find('Warsaw', 'Prague', Date.today + 1)
pp results


puts 'This is the end of the program'
