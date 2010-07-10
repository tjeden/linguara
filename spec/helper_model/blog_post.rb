class BlogPost < ActiveRecord::Base  
  translates_with_linguara :title, :body, :send_on => :save
end