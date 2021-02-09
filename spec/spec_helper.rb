require 'bundler/setup'
require 'simplecov'

SimpleCov.start
SimpleCov.minimum_coverage 90

require './autoload.rb'
require 'rack/test'
require 'capybara/rspec'
require 'rack_session_access/capybara'

Capybara.app = Rack::Builder.parse_file('config.ru').first

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Capybara::DSL

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end
