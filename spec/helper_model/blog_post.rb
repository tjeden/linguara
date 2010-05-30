class BlogPost < ActiveRecord::Base  
  translates_with_linguara :title, :body
end