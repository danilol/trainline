require './lib/scraper/thetrainline.rb'
require 'debug'

puts "This is the beginning of the program!!\n\n"

# The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`
results = Scraper::Thetrainline.find('London', 'Paris', Date.today + 1)

pp results

puts "\n\nThis is the end of the program!!"

# Other existing journey files:
# Scraper::Thetrainline.find('Munich', 'Hamburg', Date.today + 1);
# Scraper::Thetrainline.find('Lisboa', 'Faro', Date.today + 1);
# Scraper::Thetrainline.find('Paris', 'Marseille', Date.today + 1);
# Scraper::Thetrainline.find('Roma', 'Venezia', Date.today + 1);
# Scraper::Thetrainline.find('Warsaw', 'Prague', Date.today + 1);
# Scraper::Thetrainline.find('Berlin', 'Prague', Date.today + 1);
