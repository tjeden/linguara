module Linguara
  class Configuration
    attr_accessor :api_key, :server_path, :return_url, :user, :password, :request_valid_for, :site_url, :log
    
    def initialize
      self.log = true
      self.request_valid_for = lambda { Date.today + 1.month }
    end
  end
end