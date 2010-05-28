require 'net/http'
require 'uri'
require 'linguara/configuration'

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
  end
end

ActiveRecord::Base.send(:include, Linguara::ActiveRecord)