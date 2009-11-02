require 'rubygems'
require 'spec'
require 'spec/autorun'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'style_train'
                    
Spec::Runner.configure do |config|
end

