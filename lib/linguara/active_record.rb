module Linguara
  module ActiveRecord
    def self.included(base)
      base.extend LinguaraMethods
    end
      
    module LinguaraMethods
      def translates_with_linguara(*attr_names)
        include InstanceMethods
        
        class_inheritable_accessor :linguara_translation_attribute_names
              
        self.linguara_translation_attribute_names = attr_names.map(&:to_sym)

        before_save :send_to_linguara 
      end
    end
    
    module InstanceMethods
      
      def fields_to_send
        prepared_fields =  {}
        linguara_translation_attribute_names.each do |name|
          prepared_fields[linguara_key_name(name)] = { :id => linguara_key_name(name), :content => self.send(name) }
        end 
        prepared_fields
      end
      
     protected
      
      def linguara_key_name(field)
        "#{self.class.class_name}_#{self.id}_#{field}"
      end      

      def send_to_linguara
        Linguara.send_request(self)
      end 
     
    end
  end
end