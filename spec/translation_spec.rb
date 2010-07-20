require 'spec/spec_helper'

describe Translation do
  subject do
    @blog_post = BlogPost.new( :title => "Title text", :body => "Body text")
    Translation.new(@blog_post)
  end
  
  it 'creates default due_date on default' do
    subject.to_hash[:due_date].should eql(Date.today + Linguara.configuration.request_valid_for.to_i.days)
  end
  
  it 'creates return_url on default' do
    subject.to_hash[:return_url].should eql(Linguara.configuration.return_url)
  end
  
  it 'sets source language on default' do
    subject.to_hash[:source_language].should eql(I18n.locale.to_s)
  end

  it 'creates paragraphs for model' do
    subject.to_hash[:paragraphs].should eql(@blog_post.fields_to_send)
  end
end