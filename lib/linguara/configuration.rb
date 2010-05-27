module Linguara
  class Configuration
    OPTIONS = [:api_key, :server_path]
    
    attr_accessor :api_key, :server_path, :return_url, :user, :password
    
    def initialize
    end
  end
end