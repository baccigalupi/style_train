require 'rubygems'
require 'rake'

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

task :default => :spec   

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "StyleTrain"
    gem.summary = %Q{StyleTrain helps CSS with Ruby color classes}
    gem.description = %Q{StyleTrain helps CSS with Ruby color classes}
    gem.email = "baccigalupi@gmail.com"
    gem.homepage = "http://github.com/baccigalupi/style_train"
    gem.authors = ["Kane Baccigalupi"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end      

