module Linguara
  module ActiveRecord
    def self.included(base)
      base.extend LinguaraMethods
    end
      
    module LinguaraMethods
      def translates_with_linguara(*attr_names)
        include InstanceMethods
        
        after_save :send_to_linguara 
      end
    end
    
    module InstanceMethods
      protected
      def send_to_linguara
        url = URI.parse('http://86.111.247.170/pl/translations')
        req = Net::HTTP::Post.new(url.path)
        req.body = serialize_form_data({
          :return_url => 'maverick.kumulator.com:82/linguara',
          :due_date => 3.days.from_now,
          :source_language =>"pl", 
          :target_language =>"en",
          :paragraph  => { :olo_token => { :id1 => 'content'}},
          :account_token => Linguara.configuration.api_key})
        req.content_type = 'application/x-www-form-urlencoded'
        req.basic_auth '',''
        
        logger.info(req.method)
        logger.info(req.path)
        logger.info(req.body)
        logger.info(req.body_stream)
        
        res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }   
        
        logger.info(res.code)
        logger.info(res.message)
        logger.info(res.body)
      end
      
      # http://www.keyongtech.com/5211204-nested-http-params-on-ruby
      def serialize_form_data(data, path = "",serialized_params = [])
        return "dupa"
        if data.kind_of? Hash
          data.each_pair{|k,v| token = (path == "" ? url_encode(k) :  "[#{url_encode(k)}]"); serialize_form_data(v, "#{path}#{token}",serialized_params)}
        elsif data.kind_of? Array
          data.each{|v| serialize_form_data(v, "#{path}[]", serialized_params) }
        else
          #end of recursion
          serialized_params << "#{path}=#{url_encode(data)}"
        end

        return serialized_params.join("&") if (path == "")
      end
    end
  end
end