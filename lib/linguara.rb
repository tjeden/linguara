require 'net/http'
require 'uri'
require 'nokogiri'
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
    
    # Use this method in your controller to accept and save incoming translations
    def accept_translation(body, params)
      #raise ActiveRecord::StatementInvalid, 'Authorization data is missing or invalid' #TODO
      raise 'Malformed request body' if params[:translation].blank?
      target_language = params[:translation][:target_language]

      doc = Nokogiri::XML(body)

      paragraphs = doc.xpath('/translation/completed_translation/content/paragraph')
      paragraphs.each do |p|
        log("DOC: #{p.attribute('id')} --- #{p.inner_html}")
        key = p.attribute('id').to_s
        value = p.inner_html.to_s

        linguara_name, class_name,id,order,field_name = key.split('_')
        original_locale = I18n.locale
        element = class_name.constantize.find(id)
        
        I18n.locale = target_language
        element.send("#{field_name}=", value.gsub(/<p>(.*?)<\/p>/, "\\1\n") ).gsub(/<br {0,1}\/{0,1}>/, "\n")
        element.save(false)
        I18n.locale = original_locale
      end
    end
    
    # Sends translation request
    def send_translation_request(element, options = {})
      translation = Translation.new(element, options) 
      url= URI.parse("#{Linguara.configuration.server_path}api/translations.xml")
      send_linguara_request(url, :post, translation.to_xml(strip_blank_attributes(options).merge(authorization_options)))
    end

    # Sends status request
    def send_status_query(translation_request_id)
      url= URI.parse("#{Linguara.configuration.server_path}api/translations/#{translation_request_id}/status.xml")
      send_linguara_request(url, :post, authorization_xml)
    end
    
    # Sends languages request
    def send_languages_request(options={})
      url= URI.parse("#{Linguara.configuration.server_path}api/languages.xml")
      send_linguara_request(url, :get, options_to_xml(options))
    end
    
    # Sends specializations request
    def send_specializations_request(options = {})
      url= URI.parse("#{Linguara.configuration.server_path}api/specializations.xml")
      send_linguara_request(url, :get, options_to_xml(options))
    end
    
    # Sends translators request
    def send_translators_request(options = {})
      url= URI.parse("#{Linguara.configuration.server_path}api/translators.xml")
      send_linguara_request(url, :get, options_to_xml(options))
    end
    
    def available_languages
      Nokogiri::XML(send_languages_request.response.body).xpath("//language").map do |element|
        [element.xpath('name').inner_text, element.xpath('code').inner_text]
      end
    end
    
    def available_specializations
      Nokogiri::XML(send_specializations_request.response.body).xpath("//specialization").map do |element|
        [element.xpath('name').inner_text, element.xpath('id').inner_text]
      end
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

    def authorization_options
      {
        :site_url => Linguara.configuration.site_url,
        :account_token => Linguara.configuration.api_key
      }
    end

    def authorization_xml
      "<translation><site_url>#{Linguara.configuration.site_url}</site_url><account_token>#{Linguara.configuration.api_key}</account_token></translation>"
    end

    def prepare_request(url, method, data)
      if method == :get
        req = Net::HTTP::Get.new(url.path)
      else
        req = Net::HTTP::Post.new(url.path)
      end
      #log("BODY ----- :\n\n #{data}")
      req.body = "#{data}"
      req.content_type = 'text/xml'
      req.basic_auth(Linguara.configuration.user, Linguara.configuration.password)
      req
    end

    def send_linguara_request(url, method, data = '' )
      req = prepare_request url, method, data
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