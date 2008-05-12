__DIR__ = File.dirname(__FILE__)
$:.push File.join(__DIR__, '..', 'lib')

require 'rubygems'
require 'merb-core'
require 'spec'
require 'dm-validations'
require 'dm-aggregates'
require 'data_mapper'
require 'merb-mailer'

DataMapper.setup(:default, "sqlite3://localhost/test.db")

require File.join(__DIR__,'application')

Merb::BootLoader.before_app_loads do
  require 'can_has_auth_core'
end

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => 'test',:session_store => 'memory')


Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end


