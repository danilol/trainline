require_relative 'lib/scraper/the_trainline'
require 'date'

puts 'This is the beginning of the program'

# * The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`

Scraper::TheTrainline.find('London', 'Paris', DateTime.now)

puts 'This is the end of the program'