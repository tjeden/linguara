module Linguara
  class Configuration
    attr_accessor :api_key, :server_path, :return_url, :user, :password, :request_valid_for, :site_url, :log, :return_request
    
    def initialize
      self.log = true
      self.request_valid_for = 30
    end
  end
end