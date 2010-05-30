def prepare_database
  config = { :adapter => 'sqlite3', :database => ':memory:' }
  ActiveRecord::Base.establish_connection(config)
  schema_path ||= File.expand_path(File.dirname(__FILE__) + '/../data/schema.rb')
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.silence { load(schema_path) }
end