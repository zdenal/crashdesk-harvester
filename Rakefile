#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rspec/core/rake_task'
require './harvester'
require 'rake'

Dir.glob('lib/tasks/*.rake').each { |r| import r }

desc "run specs"
RSpec::Core::RakeTask.new
