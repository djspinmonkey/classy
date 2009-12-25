require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "classy"
    gem.summary = %Q{A collection of modules to enhance the capabilities of Ruby classes in various ways.}
    gem.description = %Q{Classy is a collection of metaprogramming-heavy modules which you can extend in order to give various capabilities to your Ruby classes.  For example, SubclassAware lets a class know about all of its subclasses (and sub-subclasses, etc), and Aliasable lets you refer to classes via symbols (useful for creating friendly DSLs).}
    gem.email = "github@djspinmonkey.com"
    gem.homepage = "http://github.com/djspinmonkey/classy"
    gem.authors = ["John Hyland"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
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
  rdoc.title = "classy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
