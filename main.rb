require_relative 'lib/scraper/the_trainline'
require 'date'
require 'capybara'
require 'capybara/cuprite'

require 'debug'


puts 'This is the beginning of the program'

# * The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`

Capybara.default_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
Capybara::Cuprite::Driver.new(app, headless: true, window_size: [1280, 800])
end
@session = Capybara::Session.new(:cuprite)

origin = URI.encode_www_form_component("urn:trainline:generic:loc:7527")
destination = URI.encode_www_form_component("urn:trainline:generic:loc:4922")
date = URI.encode_www_form_component("2025-11-20")
url ="https://www.thetrainline.com/book/results?origin=#{origin}&destination=#{destination}&outwardDate=#{date}"

@session.visit(url)

# Scraper::TheTrainline.find('London', 'Paris', DateTime.now)

puts 'This is the end of the program'


