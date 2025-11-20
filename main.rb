require './lib/scraper/the_trainline.rb'

require 'debug'

puts 'This is the beginning of the program'

# * The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`

# urn = Scraper::TheTrainline::UrnLocator.find_urn('Londres')
# pp urn
 results = Scraper::TheTrainline.find('London', 'Paris', Date.today + 1)
# results2 = Scraper::TheTrainline.find('Munich', 'Hamburg', Date.today + 1)
# results3 = Scraper::TheTrainline.find('Lisboa', 'Faro', Date.today + 1)
# results4 = Scraper::TheTrainline.find('Paris', 'Marseille', Date.today + 1)
# results5 = Scraper::TheTrainline.find('Roma', 'Venezia', Date.today + 1)
# results6 = Scraper::TheTrainline.find('Warsaw', 'Prague', Date.today + 1)
pp results


puts 'This is the end of the program'
