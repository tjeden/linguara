class LinguaraRequest
  
  attr_accessor :request, :response
  
  def initialize(options = {})
    self.request = options[:request]
    self.response = options[:response]
  end
end
