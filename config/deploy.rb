require 'bundler/capistrano'
require 'rvm/capistrano'

set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "deploy@176.58.123.103"
role :app, "deploy@176.58.123.103"
role :db,  "deploy@176.58.123.103", :primary => true

# Bundler
set :bundle_without, [:development, :test]

# Source code
set :application, "crashdesk-harvester"
set :scm, :git
set :repository, "git@github.com:zdenal/crashdesk-harvester.git"
set :repository_cache, "git_cache"
set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true, :port => 1499 }
set :deploy_to, "/mnt/app/#{application}"

set :rvm_ruby_string, '1.9.3-p194@crashdesk-harvester'
set :rvm_bin_path, '/usr/local/rvm/bin'
set :rvm_type, :system

set :workers, { "CrashLogs" => 5 }

default_run_options[:pty] = true

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
namespace :deploy do

  desc "restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails."
    task t, :roles => :app do ; end
  end

end

namespace :resque do
  desc "restarting workers"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RACK_ENV=#{rails_env} #{rake} resque:restart_workers"
  end
end

before 'deploy:setup', 'rvm:install_ruby'
after "deploy:restart", "resque:restart"
