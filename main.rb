require_relative 'lib/scraper/the_trainline'
require 'date'
require 'capybara'
require 'capybara/cuprite'

require 'debug'

puts 'This is the beginning of the program'

# * The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`
results = Scraper::TheTrainline.find('London', 'Berlin', DateTime.now)
pp results

puts 'This is the end of the program'


