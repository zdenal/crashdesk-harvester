require File.join(File.dirname(__FILE__), '..', 'harvester.rb')

require 'sinatra'
require 'rack/test'
require 'factory_girl'
require 'database_cleaner'
require "mocha/api"

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

def app
  Sinatra::Application
end

Dir[File.dirname(__FILE__)+"/factories/*.rb"].each {|file| require file }

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Rack::Test::Methods

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.before(:all) do
    DatabaseCleaner.clean
  end
end
