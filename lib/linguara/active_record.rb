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
      
     protected
      
      def linguara_key_name(field, index)
        "#{self.class.class_name}_#{self.id}_#{index}_#{field}"
      end

      #override this if you want to have a customised method for determining which language to use.
      def linguara_default_translation_language
        'en'
      end

      def send_to_linguara(target_language = nil, due_date = nil)
        target_language ||= linguara_default_translation_language
        Linguara.send_request(self, target_language, due_date )
      end 
     
    end
  end
end