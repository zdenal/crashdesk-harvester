require './harvester.rb'

set :environment, ENV['RACK_ENV'] || :production
set :app_file,     'harvester.rb'
disable :run

log = File.new("logs/#{ENV['RACK_ENV']}.log", "a+")
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application
