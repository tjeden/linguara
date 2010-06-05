require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Linguara" do
  it "should sent message to linguara for translatable classes" do
    FakeWeb.register_uri(:post, 'http://www.example.com/', :exception => Net::HTTPError)  
    blog_post = BlogPost.new( :title => "Title text", :body => "Body text")
    lambda { 
      blog_post.save
    }.should raise_error(Net::HTTPError)
  end
end

describe 'Linguara::ActiveRecord' do
  it "should prepare fields to translation" do
    blog_post = BlogPost.new( :title => "Title text", :body => "Body text")
    fields_to_send = blog_post.fields_to_send.to_a.sort { |a,b| a[0] <=> b[0] }
    fields_to_send.size.should eql(2)
    # It's complicated becouse linguara API is complicated. It will be much simplier in future
    fields_to_send.first[1][:content].should eql("Title text")
    fields_to_send.last[1][:content].should eql("Body text")
  end
end
