require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Linguara" do
  
  it "sent message to linguara for translatable classes" do
    FakeWeb.register_uri(:post, 'http://www.example.com/api/translations.xml', :exception => Net::HTTPError)  
    blog_post = BlogPost.new( :title => "Title text", :body => "Body text")
    lambda { 
      blog_post.save
    }.should raise_error(Net::HTTPError)
     FakeWeb.clean_registry
  end
  
  it 'accepts correct translation' do
     FakeWeb.register_uri(:post, 'http://www.example.com/', :body => 'response_for_linguara', :status => 200)
     FakeWeb.register_uri(:post, 'http://www.example.com/api/translations.xml', :status => 200) 
     blog_post = BlogPost.new( :title => "Old title", :body => "Old body")
     blog_post.save
     id = blog_post.id
     lambda {
       Linguara.accept_translation("<translation><completed_translation><content><paragraph id='linguara_BlogPost_#{id}_0_body'>Today is great weather, and I am going to EuRuKo.</paragraph><paragraph id='linguara_BlogPost_#{id}_0_title'>Hello World!</paragraph></content></completed_translation></translation>", {:translation => { :source_language =>"pl", :target_language =>"en"}}
       )
     }.should change(BlogPost, :count).by(0)
     translation = BlogPost.last
     translation.title.should eql("Hello World!")
     translation.body.should eql("Today is great weather, and I am going to EuRuKo.")
  end
  
  describe '#send_translation_request' do
    it 'sends request' do
      blog_post = BlogPost.new( :title => "Old title", :body => "Old body")
      FakeWeb.register_uri(:post, "http://www.example.com/api/translations.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_translation_request(blog_post).response
      response.body.should eql('response_from_linguara')
    end     
  end
  
  describe '#send_status_query' do
    it 'sends request' do
      FakeWeb.register_uri(:post, "http://www.example.com/api/translations/5/status.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_status_query(5).response
      response.body.should eql('response_from_linguara')
    end     
  end
  
  describe '#send_languages_request' do
    it 'sends request' do
      FakeWeb.register_uri(:get, "http://www.example.com/api/languages.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_languages_request("city"=>"321", "specialization"=>"technical", "country"=>"pl", "native_speaker"=>"1", "max_price"=>"12").response
      response.body.should eql('response_from_linguara')
    end
  end
  
  describe '#send_specializations_request' do
    it 'sends request' do
      FakeWeb.register_uri(:get, "http://www.example.com/api/specializations.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_specializations_request("language"=>"suomi", "sworn" => "1", "native_speaker"=>"1", "max_price"=>"12").response
      response.body.should eql('response_from_linguara')
    end
  end
  
  describe '#send_translators_request' do
    it 'sends request' do
      FakeWeb.register_uri(:get, "http://www.example.com/api/translators.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_translators_request("city"=>"warsaw", "country"=>"pl", "max_price"=>"12", "query"=>"wojcisz", "target_language"=>"en", "source_language" => "pl").response
      response.body.should eql('response_from_linguara')
    end
  end
  
  describe '#prepare_request' do
    before :each do
      @url = URI.parse("http://www.example.com/api/translations")
      @data = '<translation><site_url>text.com</site_url><account_token>abcdefg</account_token></translation>'
    end
    
    it 'sets :POST by deafault' do
      request = Linguara.send(:prepare_request, @url, :post, @data)
      request.is_a?(Net::HTTP::Post).should be_true
      request.body.include?("post").should be_false
    end
    
    it 'sets :GET when option given' do
      request = Linguara.send(:prepare_request, @url, :get, @data)
      request.is_a?(Net::HTTP::Get).should be_true
      request.body.include?("get").should be_false
    end
    
    it 'sets content type to text/xml' do
      request = Linguara.send(:prepare_request, @url, :get, @data)
      request.content_type.should be_eql("text/xml")
    end
  
  end
  
  describe '#available_languages' do
    before :each do 
      @response_body = "<?xml version='1.0' encoding='UTF-8'?>
        <languages>
          <language>
            <code>pl</code>
            <name>Polish</name>
          </language>
          <language>
            <code>en</code>
            <name>English</name>
          </language>
          <language>
            <code>tlh</code>
            <name>Klingon</name>
          </language>
       </languages>"
      FakeWeb.register_uri(:get, "http://www.example.com/api/languages.xml", :body => @response_body, :status => 200)      
    end
    
    it 'returns array with languages and codes' do
      expected_array = [['Polish','pl'],['English','en'],['Klingon','tlh']]
      Linguara.available_languages.should eql(expected_array)
    end
  end

  describe '#available_specializations' do
    before :each do 
      @response_body = "<?xml version='1.0' encoding='UTF-8'?>
        <specializations>
          <specialization>
            <id>2</id>
            <name>IT</name>
          </specialization>
          <specialization>
            <id>3</id>
            <name>Architecture</name>
          </specialization>
       </specializations>"
      FakeWeb.register_uri(:get, "http://www.example.com/api/specializations.xml", :body => @response_body, :status => 200)      
    end
    
    it 'returns array with languages and codes' do
      expected_array = [['IT','2'],['Architecture','3']]
      Linguara.available_specializations.should eql(expected_array)
    end
  end
end

describe 'Linguara::ActiveRecord' do
  it "should prepare fields to translation" do
    blog_post = BlogPost.new( :title => "Title text", :body => "Body text")
    fields_to_send = blog_post.fields_to_send.to_a.sort { |a,b| a[0] <=> b[0] }
    fields_to_send.size.should eql(2)
    fields_to_send.first[1].should eql("Title text")
    fields_to_send.last[1].should eql("Body text")
  end
end

