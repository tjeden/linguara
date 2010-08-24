module Linguara
  module Utils
      
    def strip_blank_attributes(data)
      data = data.each_pair { |k,v| v.is_a?(Hash) ? (strip_blank_attributes(v)) : (v) }
      data.delete_if { |k,v| v.blank?}
    end

    def options_to_xml(options)
      return '' if options.blank?
      xml = Builder::XmlMarkup.new
      xml.request do
        options.each_pair do |k, v|
          next if k.blank? or v.blank?
          tag_element(xml, k, v)
        end
      end
      return xml.target!
    end

    private

    def options_to_xml_recursive(xml, object)
      object.each_pair do |k, v|
        next if k.blank? or v.blank?
        tag_element(xml, k, v)
      end
    end

    def tag_element(builder, k, v)
      if v.kind_of?(Hash)
        builder.tag!(k) do
          options_to_xml_recursive(builder, v)
        end
      else
        builder.tag!(k, v)
      end
    end

  end
end