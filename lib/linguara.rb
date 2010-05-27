require 'rubygems'
require 'mechanize'
require 'linguara/configuration'

module Linguara
  autoload :ActiveRecord, 'linguara/active_record'
  
  class << self
    attr_accessor :configuration
    
    def configure(silent = false)
      self.configuration ||= Configuration.new
      yield(configuration)
    end
    
  end
end

ActiveRecord::Base.send(:include, Linguara::ActiveRecord)