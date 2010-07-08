module Linguara
  class Configuration
    attr_accessor :api_key, :server_path, :return_url, :user, :password, :request_valid_for, :site_url
    
    def initialize
    end
  end
end