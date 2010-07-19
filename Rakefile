require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "linguara"
    gem.summary = %Q{Gem to integrate with linguara api}
    gem.description = %Q{Gem to integrate with linguara api}
    gem.email = "aleks@kumulator.pl"
    gem.homepage = "http://github.com/tjeden/linguara"
    gem.authors = ["Aleksander Dabrowski", "Piotr Barczuk"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.files += FileList['lib/**/*.rb']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "linguara #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :metric do
  FLAY_MAX = 100
  correct = true
  metric_output = %x[flay -s lib/*]
  if metric_output.first.gsub("Total score (lower is better) = ","").to_i > FLAY_MAX
    correct = false 
    puts "Too much flay. It should be less than: #{FLAY_MAX}"
    puts metric_output
  end
  exit(1) unless correct
end