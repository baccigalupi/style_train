require 'rubygems'
require 'rake'

require 'rspec'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec   

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "style_train"
    gem.summary = %Q{style_train builds CSS with Ruby}
    gem.description = %Q{style_train builds CSS using pure Ruby, not a DSL interpreted via Ruby. This allows inheritance, modules, instance level calculations and all the goodness Ruby can offer.}
    gem.email = "baccigalupi@gmail.com"
    gem.homepage = "http://github.com/baccigalupi/style_train"
    gem.authors = ["Kane Baccigalupi"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end      

