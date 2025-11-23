require 'bundler/setup'
require 'debug'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
Dir[File.expand_path('../lib/**/*.rb', __dir__)].sort.each { |file| require file }

FIXTURES_PATH = File.expand_path('fixtures', __dir__)

def fixture(file)
  File.read(File.join(FIXTURES_PATH, file))
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    # Disable logging globally during test suite
    Scraper::Thetrainline.send(:remove_const, :LOGGER)
    Scraper::Thetrainline::LOGGER = Scraper::Thetrainline::Logger.new(enabled: false)
  end
end
