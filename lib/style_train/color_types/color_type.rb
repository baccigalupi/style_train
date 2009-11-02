class ColorType
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
   
  attr_accessor :r, :g, :b 
  attr_reader :alpha
  
  def initialize( opts )
    self.alpha = opts[:alpha]
  end
  
  def alpha=( value )
    value = (value || 1.0).to_f
    raise AlphaError if value > 1.0 || value < 0.0
    @alpha = value 
  end    
      
  # These can't contain real classes because it will create a dependency loop.
  def self.color_opts
    @color_opts ||= Mash.new(
      :rgb => 'RGBcolor',
      :hsl => 'HSLcolor',
      :keyword => 'KeywordColor', 
      :hex => 'HexColor'
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
     
  # Builds to_rgb ... etc
  color_opts.keys.each do |color_type|
    class_eval "
      def to_#{color_type}( color )
        to( :#{color_type} )
      end  
    "    
  end 
        
  def to( color_type )
    klass = color_type_class(color_type)
    raise ArgumentError, 'color type not supported' unless klass
    self.class == klass ? self : klass.new( self )
  end
  
  def to_s
    raise ImplementationError, 'Subclasses of ColorType must implement #to_s'   
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