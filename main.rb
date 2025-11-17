require_relative 'lib/scraper/the_trainline'
require 'date'
require 'capybara'
require 'capybara/cuprite'

require 'debug'


puts 'This is the beginning of the program'

# * The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`

Capybara.default_driver = :cuprite
Capybara.default_max_wait_time = 20

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    headless: false,
    window_size: [1280, 900],
    timeout: 30,
    process_timeout: 40,
    js_errors: false
  )
end

session = Capybara::Session.new(:cuprite)

origin = URI.encode_www_form_component("urn:trainline:generic:loc:7527") # London (Any)
destination = URI.encode_www_form_component("urn:trainline:generic:loc:4922") # Paris (Any)
date = URI.encode_www_form_component("2025-11-20")
url ="https://www.thetrainline.com/book/results?origin=#{origin}&destination=#{destination}&outwardDate=#{date}"

begin
  session.visit(url)

  # 1. Wait for and accept cookies (mandatory!)
  if session.has_css?('#onetrust-accept-btn-handler', wait: 10)
    session.find('#onetrust-accept-btn-handler').click
  end

  # 2. Wait for CAPTCHA resolution (you do this manually)
  puts "Solve captcha if needed..."
  sleep 2 # or wait until captcha disappears


  # 3. Wait for journey list hydration
  puts "Wait for journey list hydration..."
  session.has_css?('[role="tabpanel"]', wait: 20)

  # 4. Wait for at least one journey row to exist
  puts "Wait for at least one journey row to exist..."
  session.has_css?('[data-test*="journey-row"], [id^="result-row-journey-"]', wait: 20)

  # Let Trainline finish last DOM updates
  session.has_no_css?('[data-test="loading"]', wait: 15) rescue nil
  sleep 1.5

  # 5. ONLY NOW call the parser
  puts "Only now call the parser..."

#  scraper = Scraper::TheTrainline.new('London', 'Paris', DateTime.now)
  fixture = Scraper::TheTrainline::Fixture.new(from = 'London', to = 'Paris').save_fixture(session.html) 
# Now parse
  results = Scraper::TheTrainline::Parser.new(session).parse
  pp results
ensure
  session.driver.quit
end

# Scraper::TheTrainline.find('London', 'Paris', DateTime.now)

puts 'This is the end of the program'


