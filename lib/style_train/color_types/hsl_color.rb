# todo: when needed
module StyleTrain
  class HSLcolor < ColorType
    attr_accessor :h, :s, :l
    attr_reader :hue, :saturation, :lightness
    
    def hue=(value)
      @hue = value
      self.h = self.class.normalize_degrees(value)
      @hue
    end
    
    def saturation=(value)
      @saturation = value
      self.s = self.class.percentage(value)
      @saturation
    end
    
    def lightness=(value)
      @lightness = value
      self.s = self.class.percentage(value)
      @lightness
    end
    
    def type_initialize( color, opts )
      if color.is_a? Array  
        self.hue =         color[0]
        self.saturation =  color[1]
        self.lightness =   color[2] 
      else
        raise ArgumentError, 'HSL color must be initialized with a :color opts argument that is an array'
      end  
    end
  
    def build
      # r, g, b
      self
    end
  end
end     