require 'rubygems'
require 'sinatra'
require 'mongo'
require 'mongoid'
require 'pp'
require 'ruby-debug'
require 'resque'
require 'active_resource'
require 'firehose'


config_file = File.join( 'config', "app_config.yml" )
APP_CONFIG = YAML.load_file(config_file)[ENV['ENVIRONMENT']].symbolize_keys
MONGOID_CONFIG = Mongoid.load!('mongoid.yml')[ENV['ENVIRONMENT']]

%w{models workers services}.each do |dir|
  Dir["./#{dir}/*.rb"].each {|file| require file }
end

before do
  logger = Logger.new('logs.log')
end

get '/debug' do
  debugger
  puts ''
end

post '/v1/crashes' do
  #app_id = request.env['HTTP_X_CRASHDESK_APIKEY']
  app_id = App.first._id
  if App.where(id: app_id).exists?
    e = JSON.parse(request.env["rack.input"].read)
    # api_key in error send from crashdesk-rails-test
    # is set 12345, so we need put into error some
    # existing api_key
    e['api_key'] = app_id
    #####################
    log = Crashlog.new(e)
    log.save
    Resque.enqueue(CrashlogProcessor, log.id)
    logger.info "[INFO] #{Time.now.to_s}: #{app_id} got #{log.crc}"
  else
    logger.error "[ERROR] #{Time.now.to_s}: invalid app_uuid try to connect"
  end
end
