ActiveRecord::Schema.define do
  create_table :blog_posts, :force => true do |t|
    t.string   :title
    t.text     :body
  end
end