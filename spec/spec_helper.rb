$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'cgi'
require 'active_record'
require 'active_support'
require 'helper_model/database_mock'
require 'linguara'
require 'helper_model/blog_post'
require 'spec'
require 'spec/autorun'
require 'fakeweb'

prepare_database

Linguara.configure do |config|
  config.api_key = 'api_keu'
  config.server_path = 'http://www.example.com/'
  config.return_url = 'http://maverick.kumulator.com:82/linguara'
  config.log = false
end

Spec::Runner.configure do |config|
  
end

