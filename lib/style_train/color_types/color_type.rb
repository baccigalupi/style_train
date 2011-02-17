module StyleTrain
  class ColorType 
    # ERROR CLASSES
    class PercentageError < ArgumentError
      def message 
        @message ||= 'Percentages must be between 0 and 100'
      end
    end 
  
    class ByteNumberError < ArgumentError
      def message 
        @message ||= 'Byte numbers must be between 0 and 255'
      end
    end
  
    class AlphaError < ArgumentError
      def message 
        @message ||= 'Alpha must be between 0.0 and 1.0'
      end
    end
  
    # ATTRIBUTES  
    attr_accessor :r, :g, :b 
    attr_reader :alpha 
  
    # INITIALIZATION
    def initialize( opts )
      if self.class.is_color?(opts)
        build_from_color(opts)
      else
        opts = Gnash.new(opts)
        color = opts[:color]
        self.alpha = opts[:alpha] 
        type_initialize( color, opts )
      end  
    end
  
    def type_initialize( color, opts ) 
      raise NotYetImplemented, "type_initialize must be implemented for #{self}"
    end  
  
    def alpha=( value ) 
      value = (value || 1.0).to_f   
      raise AlphaError if value > 1.0 || value < 0.0
      @alpha = value 
    end 
  
    def build_from_color( color ) 
      self.r = color.r
      self.g = color.g
      self.b = color.b
      self.alpha = color.alpha
      build
    end 
  
    def build 
      raise NotImplementedError, "#build must be implemented for #{self.class}"
    end   
  
    def self.is_color?( color )
      color.is_a? ColorType 
    end 
  
    # INSTANCE METHODS 
    # conversion
    def to( color_type )
      klass = self.class.color_type_class(color_type)
      raise ArgumentError, 'color type not supported' unless klass
      self.class == klass ? self : klass.new( self )
    end
  
    # comparison
    def =~( color )
      if color.is_a?( ColorType ) 
        self.r == color.r && self.g == color.g && self.b == color.b 
      elsif color.is_a?( Color )
        self =~ color.delegate
      end    
    end
  
    def ==( color )
      (self =~ color) && self.alpha == color.alpha
    end 
  
    def ===( color )
      (self == color) && self.class == color.class
    end 
  
    # blending
    def mix( color )
      mixed = self.dup
      mixed.r = self.class.average(self.r, color.r)
      mixed.g = self.class.average(self.g, color.g)
      mixed.b = self.class.average(self.b, color.b)
      mixed.alpha = self.class.average(self.alpha, color.alpha, false)
      mixed.build
      mixed
    end
  
    def layer( color )
      layered = self.dup 
      ratio = 1 - color.alpha
      layered.r = self.class.blend( self.r, color.r, ratio )
      layered.g = self.class.blend( self.g, color.g, ratio )
      layered.b = self.class.blend( self.b, color.b, ratio )
      layered.alpha = self.class.blend_alphas( self.alpha, color.alpha ) 
      layered.build
      layered
    end
  
    def self.blend(first, second, ratio) 
      blended = (first*ratio + second*(1-ratio)).round
    end    
  
    def self.average(first, second, round=true)
      averaged = ((first + second)/2.0)
      round ? averaged.round : averaged
    end 
  
    def self.blend_alphas(first, second)
      base, blender = first > second ? [first, second] : [second, first]
      difference = 1.0 - base
      base + difference * blender
    end         
  
    # rendering
    def render(opts=nil) 
      alpha? ? render_as_rgba : render_as_given
    end
  
    def to_s(opts=nil)
      render(opts)
    end   
  
    def render_as_given 
      raise NotImplementedError, "#render_as_given must be implemented for #{self.class}"
    end     
  
    def render_as_rgba
      "rgba( #{self.r}, #{self.g}, #{self.b}, #{self.alpha} )"
    end
  
    def alpha?
      self.alpha != 1.0
    end    
  
    # CLASS METHODS 
  
    def self.make(opts)
      begin
        new(opts)
      rescue
        nil
      end    
    end  
      
    # These can't contain real classes because it will create a dependency loop.
    def self.color_opts
      @color_opts ||= Gnash.new(
        :rgb => 'StyleTrain::RGBcolor',
        :keyword => 'StyleTrain::KeywordColor', 
        :hex => 'StyleTrain::HexColor' 
        # :hsl => 'HSLcolor' # when this class exists
      ) 
    end 
   
    # So they are replaced on usage with the actual constants, as needed
    def self.color_type_class( color_type )
      klass = color_opts[ color_type ]
      if klass.class == String
        color_opts[color_type] = klass.constantize
      else
        klass
      end   
    end
  
    def self.color_types  
      unless @types_built
        color_opts.each do |key, klass|
          self.color_type_class( key )
        end  
        @types_built = true
      end   
      color_opts.values
    end      
  
    def self.percentage( str )
      if str.class == String && str.match(/^([\d.]*)%$/) 
        number = $1.to_f
        raise PercentageError if number > 100.0 || number < 0.0
        number
      else  
        false
      end  
    end
  
    def self.byte( str ) 
      str.to_i if valid_byte?( str, true )    
    end
  
    def self.valid_byte?( number, raise_exe=false )
      num = number.to_i
      v = num <= 255 && num >= 0 
      raise ByteNumberError if v != true && raise_exe
      v
    end  
  
    def self.percent_to_byte( number ) 
      raise PercentageError  if number > 100.0 || number < 0.0 
      ( number * 2.55 ).round
    end
  
    def self.byte_to_percentage( number )
      raise ByteNumberError if number > 255.0 || number < 0.0 
      ( number/2.55 ).round
    end                
  end
end 