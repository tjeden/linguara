require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Linguara" do
  
  it "sent message to linguara for translatable classes" do
    FakeWeb.register_uri(:post, 'http://www.example.com/api/create_translation_request.xml', :exception => Net::HTTPError)  
    blog_post = BlogPost.new( :title => "Title text", :body => "Body text")
    lambda { 
      blog_post.save
    }.should raise_error(Net::HTTPError)
     FakeWeb.clean_registry
  end
  
  it 'accepts correct translation' do
     FakeWeb.register_uri(:post, 'http://www.example.com/', :body => 'response_for_linguara', :status => 200)  
     blog_post = BlogPost.new( :title => "Old title", :body => "Old body")
     blog_post.save
     id = blog_post.id
     lambda {
       Linguara.accept_translation(            
            :paragraphs => {
             "BlogPost_#{id}_0_title" => "Hello World!",
             "BlogPost_#{id}_1_body" => "Today is great weather, and I am going to EuRuKo."
            },
           :source_language =>"pl", 
           :target_language =>"en"
       )
     }.should change(BlogPost, :count).by(0)
     translation = BlogPost.last
     translation.title.should eql("Hello World!")
     translation.body.should eql("Today is great weather, and I am going to EuRuKo.")
  end
  
  describe '#send_translation_request' do
    it 'sends request' do
      blog_post = BlogPost.new( :title => "Old title", :body => "Old body")
      FakeWeb.register_uri(:post, "http://www.example.com/api/create_translation_request.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_translation_request(blog_post)
      response.body.should eql('response_from_linguara')
    end     
  end
  
  describe '#send_status_query' do
    it 'sends request' do
      FakeWeb.register_uri(:post, "http://www.example.com/api/5/translation_status.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_status_query(5)
      response.body.should eql('response_from_linguara')
    end     
  end
  
  describe '#send_languages_request' do
    it 'sends request' do
      FakeWeb.register_uri(:get, "http://www.example.com/api/languages.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_languages_request("city"=>"321", "specialization"=>"technical", "country"=>"pl", "native_speaker"=>"1", "max_price"=>"12")
      response.body.should eql('response_from_linguara')
    end
  end
  
  describe '#send_specializations_request' do
    it 'sends request' do
      FakeWeb.register_uri(:get, "http://www.example.com/api/specializations.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_specializations_request("language"=>"suomi", "sworn" => "1", "native_speaker"=>"1", "max_price"=>"12")
      response.body.should eql('response_from_linguara')
    end
  end
  
  describe '#send_translators_request' do
    it 'sends request' do
      FakeWeb.register_uri(:get, "http://www.example.com/api/translators.xml", :body => 'response_from_linguara', :status => 200) 
      response = Linguara.send_translators_request("city"=>"warsaw", "country"=>"pl", "max_price"=>"12", "query"=>"wojcisz", "target_language"=>"en", "source_language" => "pl")
      response.body.should eql('response_from_linguara')
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

