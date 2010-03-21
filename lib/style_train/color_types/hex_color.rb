class HexColor < ColorType 
  class HexError < ArgumentError 
    def message 
      @message ||= 'Hexidecimal colors should be 3 or 6 digits and can be preceded by a # sign'
    end 
  end  
  
  attr_accessor :hex, :hex_6
  
  def type_initialize( color, opts ) 
    h = color.to_s
    raise HexError unless h.match(/^#?([a-f0-9]{3,6})$/i)
    self.hex = "#{$1}"
    self.hex_6 =  self.class.expand( hex )
  end
  
  def self.to_rgb( hex_str )
    hex_str = expand( hex_str )
    # ??
  end  
      
  def self.expand( hex ) 
    if (hex.size == 3)
      str = ''
      (0..2).each do |index|
        char = hex[index..index]
        str << char*2
      end
      str
    else
      hex
    end      
  end  

end  