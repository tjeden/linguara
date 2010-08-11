module Linguara
  module Utils
      
    def strip_blank_attributes(data)
      data = data.each_pair { |k,v| v.is_a?(Hash) ? (strip_blank_attributes(v)) : (v) }
      data.delete_if { |k,v| v.blank?}
    end
  end
end