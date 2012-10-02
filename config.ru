require './harvester.rb'

set :environment, ENV['RACK_ENV'] || :production
set :app_file, 'harvester.rb'
disable :run

std_log = File.new("log/#{ENV['RACK_ENV']}.log", "a+")
STDOUT.reopen(std_log)
STDERR.reopen(std_log)

run Sinatra::Application
