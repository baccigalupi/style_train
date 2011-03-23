$LOAD_PATH.unshift( File.dirname(__FILE__) )

# Support stuff
begin
  require 'active_support/inflector'
rescue
  require 'activesupport'
end
require 'style_train/support/gnash'
require 'style_train/support/numbers'

module StyleTrain
  class << self 
    attr_accessor :dir
  end
end

# The color load!
require "style_train/color"
require 'style_train/style'
require "style_train/sheet"
require 'style_train/theme'
require 'style_train/themed_sheet'   
