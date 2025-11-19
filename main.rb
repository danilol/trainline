require './lib/scraper/the_trainline.rb'

require 'debug'

puts 'This is the beginning of the program'

# * The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`

# urn = Scraper::TheTrainline::UrnLocator.find_urn('Londres')
# pp urn
results = Scraper::TheTrainline.find('London', 'Berlin', Date.today + 1)
pp results


puts 'This is the end of the program'
