require_relative 'lib/scraper/the_trainline'
require 'date'
require 'capybara'
require 'capybara/cuprite'

require 'debug'


puts 'This is the beginning of the program'


# * The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`
scraper = Scraper::TheTrainline.find('London', 'Berlin', DateTime.now)

pp scraper



# scraper = Scraper::TheTrainline.new('London', 'Paris', DateTime.now)
# fixture = Scraper::TheTrainline::Fixture.new(from = 'London', to = 'Paris').save_fixture(session.html) 
# Now parse
# results = Scraper::TheTrainline::Parser.new(session).parse

# Scraper::TheTrainline.find('London', 'Paris', DateTime.now)

puts 'This is the end of the program'


