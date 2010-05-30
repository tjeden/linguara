require 'net/http'
require 'uri'
require 'linguara/configuration'
require 'linguara/utils'

module Linguara
  autoload :ActiveRecord, 'linguara/active_record'
  
  class << self
    attr_accessor :configuration
    
    def configure(silent = false)
      self.configuration ||= Configuration.new
      yield(configuration)
    end
    
    def accept_translation(translation)
      target_language = translation[:target_language]
      translation[:paragraph].each do |key,value|
        class_name,id,field_name = value[:id].split('_')
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
        #TODO log error
      end
    end
    
    #TODO describe it, spec and move somewhere else
     # http://www.keyongtech.com/5211204-nested-http-params-on-ruby
    def serialize_form_data(data, path = "",serialized_params = [])
       if data.kind_of? Hash
         data.each_pair{|k,v| token = (path == "" ? url_encode(k) :  "[#{url_encode(k)}]"); serialize_form_data(v, "#{path}#{token}",serialized_params)}
       elsif data.kind_of? Array
         data.each{|v| serialize_form_data(v, "#{path}[]", serialized_params) }
       else
         #end of recursion
         serialized_params << "#{path}=#{url_encode(data)}"
       end

       return serialized_params.join("&") if (path == "")
     end
  end
end

ActiveRecord::Base.send(:include, Linguara::ActiveRecord)