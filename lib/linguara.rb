require 'net/http'
require 'uri'
require 'linguara/configuration'
require 'linguara/utils'
require 'linguara/translation'
require 'linguara/request'

module Linguara
  extend Linguara::Utils
  autoload :ActiveRecord, 'linguara/active_record'
  
  class << self
    attr_accessor :configuration
    
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
    
    # Use this method in your controller to accepr and save incoming translations
    def accept_translation(translation)
      target_language = translation[:target_language]
      translation[:paragraphs].each do |key,value|
        class_name,id,order,field_name = key.split('_')
        original_locale = I18n.locale
        element = class_name.constantize.find(id)
        
        I18n.locale = target_language
        element.send("#{field_name}=", value.gsub(/<p>(.*?)<\/p>/, "\\1\n") )
        element.save(false)
        I18n.locale = original_locale
      end
    end
    
    def send_translation_request(element, options = {})
      translation = Translation.new(element, options) 
      url= URI.parse("#{Linguara.configuration.server_path}api/translations.xml")
      req = prepare_request(url, translation.to_hash.merge( :authorization => true))
      send_linguara_request(req, url)
    end

    def send_status_query(translation_request_id)
      url= URI.parse("#{Linguara.configuration.server_path}api/translations/#{translation_request_id}/status.xml")
      req = prepare_request(url, :authorization => true)
      send_linguara_request(req, url)
    end
    
    def send_languages_request(options={})
      url= URI.parse("#{Linguara.configuration.server_path}api/languages.xml")
      req = prepare_request(url, options.merge(:method => :get))
      send_linguara_request(req, url)
    end
    
    def send_specializations_request(options)
      url= URI.parse("#{Linguara.configuration.server_path}api/specializations.xml")
      req = prepare_request(url, options.merge(:method => :get))
      send_linguara_request(req, url)
    end
    
    def send_translators_request(options)
      url= URI.parse("#{Linguara.configuration.server_path}api/translators.xml")
      req = prepare_request(url, options.merge(:method => :get))
      send_linguara_request(req, url)
    end
    
    # Override this method if you want to perform some action when connection
    # with linguara cannot be established e.g. log request or redo the send
    def handle_request_error
      log("ERROR WHILE SENDING REQUEST TO LINGUARA: #{$!}")
    end
    
    # Log a linguara-specific line. Uses Rails.logger
    # by default. Set Lingurara.config.log = false to turn off.
    def log message
      logger.info("[linguara] #{message}") if logging?
    end

    def logger #:nodoc:      
      Rails.logger
    end

    def logging? #:nodoc:
      Linguara.configuration.log
    end
    
    private
    
    def prepare_request(url, data = {} )
      data = strip_blank_attributes(data)
      if data[:method] == :get
        req = Net::HTTP::Get.new(url.path)
        data.delete(:method)
      else
        req = Net::HTTP::Post.new(url.path)
      end
      if data[:authorization]   
        data.delete(:authorization)
        req.body = serialize_form_data({
          :site_url => Linguara.configuration.site_url,
          :account_token => Linguara.configuration.api_key
         }.merge(data))
      else
        req.body = serialize_form_data(data)
      end
      req.content_type = 'application/x-www-form-urlencoded'
      req.basic_auth(Linguara.configuration.user, Linguara.configuration.password)
      req
    end
    
    def send_linguara_request(req, url)
      #TODO handle timeout
      begin
        log("SENDING LINGUARA REQUEST TO #{url.path}: \n#{req.body}")
        res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
        log("LINGUARA RESPONSE: #{res.message} -- #{res.body}")
        return LinguaraRequest.new( :request => req, :response => res )
      rescue Errno::ETIMEDOUT 
        handle_request_error
      end
    end
  end
end

ActiveRecord::Base.send(:include, Linguara::ActiveRecord)