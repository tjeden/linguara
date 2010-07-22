class Translation
  
  attr_accessor :translation_hash
  
  def initialize(element,options = {})
    unless options[:translation] && options[:translation][:due_date]
      options[:translation] = Hash.new
      options[:translation][:due_date] ||= Date.today + Linguara.configuration.request_valid_for.to_i.days unless Linguara.configuration.request_valid_for.blank?
      options[:translation][:due_date] ||= Date.today + 1.month
    end
    options[:return_url] ||= Linguara.configuration.return_url
    options[:source_language] ||= I18n.locale.to_s
    options[:content] = Hash.new
    options[:content][:plain] = Hash.new
    options[:content][:plain][:paragraphs] = element.fields_to_send
    self.translation_hash = options
  end
  
  def to_hash
    self.translation_hash
  end
end