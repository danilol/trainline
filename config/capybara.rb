# frozen_string_literal: true

require 'capybara'
require 'capybara/cuprite'

Capybara.default_driver = :cuprite
Capybara.default_max_wait_time = 20

Capybara.register_driver(:cuprite) do |app|
  app_config = Scraper::Thetrainline.app_config
  Capybara::Cuprite::Driver.new(
    app,
    headless: app_config.headless,
    browser_options: {
      'disable-blink-features' => 'AutomationControlled'
    },
    window_size: [1280, 900],
    timeout: 10,
    process_timeout: 10,
    js_errors: false
  )
end