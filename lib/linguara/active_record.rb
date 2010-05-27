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
    # protected
           
     # http://www.keyongtech.com/5211204-nested-http-params-on-ruby
     def serialize_form_data(data, path = "",serialized_params = [])
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
      
      def fields_to_send
        { :olo_token => { :id => 'id1', :content => 'translate_this'}}
      end

      def send_to_linguara
        url = URI.parse(Linguara.configuration.server_path)
        req = Net::HTTP::Post.new(url.path)
        req.body = serialize_form_data({
          :translation => {
            :return_url => Linguara.configuration.return_url,
            :due_date => '27-06-2010',
            :source_language =>"pl", 
            :target_language =>"en",
            :paragraph  => fields_to_send,
            :account_token => Linguara.configuration.api_key}})
        req.content_type = 'application/x-www-form-urlencoded'
        req.basic_auth Linguara.configuration.user, Linguara.configuration.password
        
        logger.info(req.method)
        logger.info(req.path)
        logger.info(req.body)
        logger.info(req.body_stream)
        
        res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }   
        
        logger.info(res.code)
        logger.info(res.message)
        logger.info(res.body)
      end
 
     
    end
  end
end