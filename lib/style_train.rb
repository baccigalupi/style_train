$LOAD_PATH.unshift( File.dirname(__FILE__) )

# ruby libs
require 'singleton'

# Support stuff
require 'style_train/support/mash'
require 'style_train/support/string'

# The color load!
require 'style_train/color_types/color_type'
require 'style_train/color_types/rgb_color'
require 'style_train/color_types/hsl_color'
require 'style_train/color_types/keyword_color'
require 'style_train/color_types/hex_color'
require "style_train/color"
# require 'lib/palette'


# require 'set'
# require 'style'   
