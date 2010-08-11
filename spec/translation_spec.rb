require 'spec/spec_helper'

describe Translation do
  subject do
    @blog_post = BlogPost.new( :title => "Title text", :body => "Body text")
    Translation.new(@blog_post)
  end
  
  it 'creates default due_date on default' do
    subject.to_xml.should match(Regexp.new("<due_date>#{Date.today + Linguara.configuration.request_valid_for.to_i.days}</due_date>"))
  end
  
  it 'creates return_url on default' do
    subject.to_xml.should match(Regexp.new("<return_url>#{Linguara.configuration.return_url}</return_url>"))
  end
  
  it 'sets source language on default' do
    subject.to_xml.should match(Regexp.new("<source_language>#{I18n.locale.to_s}</source_language>"))
  end

  it 'creates paragraphs for model' do
    subject.to_xml.should match(Regexp.new("(<paragraph id=['|\"].*['|\"]>[^<>]+</paragraph>\s*)+"))
  end
end