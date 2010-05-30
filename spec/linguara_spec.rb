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
