require 'capybara'
require 'capybara/cuprite'

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