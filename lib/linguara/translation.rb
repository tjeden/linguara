class Translation
  
  attr_accessor :translation_hash, :element
  
  def initialize(element,options = {})
    unless options[:due_date]
      options[:due_date] ||= Date.today + Linguara.configuration.request_valid_for.to_i.days unless Linguara.configuration.request_valid_for.blank?
      options[:due_date] ||= Date.today + 1.month
    end
    options[:return_url] ||= Linguara.configuration.return_url
    options[:source_language] ||= I18n.locale.to_s
    self.element = element#.fields_to_send
    self.translation_hash = options
  end
  
  def to_hash
    ret = {}
    ret[:translation] = self.translation_hash
    ret
  end

  def to_xml(options, builder_options = {})
    builder_options[:indent] ||= 2
    xml = builder_options[:builder] ||= Builder::XmlMarkup.new(:indent => builder_options[:indent])
    xml.instruct! unless builder_options[:skip_instruct]
    xml.translation do
      self.translation_hash.merge(options).each_pair do |k, v|
        next if k.blank? or v.blank?
        Rails.logger.debug("OBJECT:#{v.inspect}")
        tag_element(xml, k, v)
      end
      xml.content :type => 'xml' do
        self.element.fields_to_send.each_pair do |k, v|
          xml.paragraph v, :id => k
        end
      end
    end
  end

  private

  def to_xml_recursive(xml, object)
    object.each_pair do |k, v|
      tag_element(xml, k, v)
    end
  end

  def tag_element(builder, k, v)
    if v.kind_of?(Hash)
      builder.tag!(k) do
        to_xml_recursive(builder, v)
      end
    else
      builder.tag!(k, v)
    end
  end
end