module Linguara
  module ActiveRecord
    def self.included(base)
      base.extend LinguaraMethods
    end
      
    module LinguaraMethods
      def translates_with_linguara(*attr_names)
        include InstanceMethods

        options = attr_names.extract_options!
        
        class_inheritable_accessor :linguara_translation_attribute_names
              
        self.linguara_translation_attribute_names = attr_names.map(&:to_sym)

        after_create :send_to_linguara if options[:send_on] == :create
        after_save :send_to_linguara if options[:send_on] == :save
      end
    end
    
    module InstanceMethods
      
      def fields_to_send
        prepared_fields =  {}
        linguara_translation_attribute_names.each_with_index do |name, index|
          key_name = linguara_key_name(name, index)
          prepared_fields[key_name] = self.send(name)
        end 
        prepared_fields
      end

      def send_to_linguara(options = {})
        options = before_send_to_linguara(options)
        res = Linguara.send_translation_request(self, options )
        after_send_to_linguara(res)
        res
      end

      def send_status_query(translation_request_id)
        Linguara.send_status_query(translation_request_id)
      end
      
     protected
      
      def linguara_key_name(field, index)
        "#{self.class.class_name}_#{self.id}_#{index}_#{field}"
      end

      #override this if you want to have a customised method for determining which language to use.
      def linguara_default_translation_language
        'en'
      end

      #override for some callbacks
      def before_send_to_linguara(options)
        options
      end

      def after_send_to_linguara(response)
      end
     
    end
  end
end