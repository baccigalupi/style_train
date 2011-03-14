module StyleTrain
  class HexColor < ColorType 
    class HexError < ArgumentError 
      def message 
        @message ||= 'Hexidecimal colors should be 3 or 6 hexidecimal digits and can be preceded by a # sign'
      end 
    end  
  
    attr_accessor :hex, :hex_6
  
    def type_initialize( color, opts ) 
      hex = color.to_s 
      raise HexError unless hex.match(/^#?([a-f0-9]{3})$/i) || hex.match(/^#?([a-f0-9]{6})$/i)
      self.hex = "#{$1}"
      self.hex_6 =  self.class.expand( self.hex ) 
      self.r = (self.hex_6 / 0x10000) & 0xff
      self.g = (self.hex_6 / 0x100) & 0xff
      self.b = (self.hex_6) & 0xff
    end
  
    def build 
      self.hex =  "%.2x" % self.r + "%.2x" % self.g + "%.2x" % self.b
      self.hex_6 = ('0x' + self.hex).to_i(16)
      self
    end  
      
    def self.expand( hex ) 
      expanded = if (hex.size == 3)
        str = ''
        (0..2).each do |index|
          char = hex[index..index]
          str << char*2
        end
        str
      else
        hex
      end
      "0x#{expanded}".to_i(16)       
    end
  
    def render_as_given
      "##{self.hex}"
    end 
  end 
end 