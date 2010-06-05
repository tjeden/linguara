require 'net/http'
require 'uri'
require 'linguara/configuration'
require 'linguara/utils'

module Linguara
  extend Linguara::Utils
  autoload :ActiveRecord, 'linguara/active_record'
  
  class << self
    attr_accessor :configuration
    
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
    
    def accept_translation(translation)
      target_language = translation[:target_language]
      translation[:paragraph].each do |key,value|
        class_name,id,order,field_name = value[:id].split('_')
        content = value[:content]
        original_locale = I18n.locale
        element = class_name.constantize.find(id)
        
        I18n.locale = target_language
        element.send("#{field_name}=", content)
        element.save(false)
        I18n.locale = original_locale
      end
    end
    
    def send_request(element)
      url= URI.parse(Linguara.configuration.server_path)
      req = Net::HTTP::Post.new(url.path)
      req.body = serialize_form_data({
        :translation => {
          :return_url => Linguara.configuration.return_url,
          :due_date => '27-06-2010',
          :source_language =>"pl", 
          :target_language =>"en",
          :paragraph  => element.fields_to_send,
          :account_token => Linguara.configuration.api_key}})
      req.content_type = 'application/x-www-form-urlencoded'
      req.basic_auth Linguara.configuration.user, Linguara.configuration.password
      #TODO handle timeout
      begin
        res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }   
      rescue Errno::ETIMEDOUT 
        handle_request_error
      end
    end
    
    # ovverride this method if you want to perform some action when connection
    # with linguara cannot be established e.g. log request or redo the send
    def handle_request_error
    end
    
  end
end

ActiveRecord::Base.send(:include, Linguara::ActiveRecord)