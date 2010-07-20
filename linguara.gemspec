# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{linguara}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aleksander Dabrowski", "Piotr Barczuk"]
  s.date = %q{2010-07-20}
  s.description = %q{Gem to integrate with linguara api}
  s.email = %q{aleks@kumulator.pl}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "init.rb",
     "lib/linguara.rb",
     "lib/linguara/active_record.rb",
     "lib/linguara/configuration.rb",
     "lib/linguara/translation.rb",
     "lib/linguara/utils.rb",
     "linguara.gemspec",
     "spec/data/schema.rb",
     "spec/helper_model/blog_post.rb",
     "spec/helper_model/database_mock.rb",
     "spec/linguara_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/translation_spec.rb"
  ]
  s.homepage = %q{http://github.com/tjeden/linguara}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Gem to integrate with linguara api}
  s.test_files = [
    "spec/data/schema.rb",
     "spec/helper_model/blog_post.rb",
     "spec/helper_model/database_mock.rb",
     "spec/linguara_spec.rb",
     "spec/spec_helper.rb",
     "spec/translation_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

