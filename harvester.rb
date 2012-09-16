require 'rubygems'
require 'sinatra'
require 'mongo'
require 'mongoid'
require 'pp'
require 'ruby-debug'
require 'resque'
require 'firehose'

ENV['RACK_ENV'] ||= 'production'
config_file = File.join( 'config', "app_config.yml" )
APP_CONFIG = YAML.load_file(config_file)[ENV['RACK_ENV']].symbolize_keys
MONGOID_CONFIG = Mongoid.load!('mongoid.yml')[ENV['RACK_ENV']]
logger = Logger.new("log/#{ENV['RACK_ENV']}_apps_info.log")

%w{models workers services}.each do |dir|
  Dir["./#{dir}/*.rb"].each {|file| require file }
end

get '/debug' do
end

post '/v1/crashes' do
  app_key = request.env['HTTP_X_CRASHDESK_APPKEY']
  #app_key = App.first._id
  if App.where(id: app_key).exists?
    e = JSON.parse(request.env["rack.input"].read)
    log = Crashlog.new(e)
    log.save
    Resque.enqueue(CrashlogProcessor, log.id)
    logger.info "[INFO] #{Time.now.to_s}: #{app_key} got #{log.crc}"
  else
    logger.error "[ERROR] #{Time.now.to_s}: invalid app_uuid try to connect"
  end
end
