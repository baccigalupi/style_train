module StyleTrain 
  class RGBcolor < ColorType
    attr_reader :red, :green, :blue # these are the entered values, not the calculated values 

    METHOD_MAP ={
      'r' => 'red',
      'g' => 'green',
      'b' => 'blue'
    } 
  
    ['red', 'green', 'blue'].each do |clr|
      class_eval " 
        def #{clr}=( value )
          @#{clr} = value
          self.#{clr[0..0]} = value  
        end 
      "
    end  
  
    ['r', 'g', 'b'].each do |clr| 
      class_eval "
        def #{clr}=( value )
          @#{clr} = normalize_internal_rgb( value )  
        end  
      "
    end
  
    def type_initialize( color, opts )
      if color.is_a? Array  
        self.red =    color[0]
        self.green =  color[1]
        self.blue =   color[2] 
      else
        raise ArgumentError, 'RGB color must be initialized with a :color opts argument that is an array' unless color && color.class == Array
      end  
    end
  
    def build
      self.red =    self.r
      self.green =  self.g
      self.blue =   self.b
    end    
  
    def normalize_internal_rgb( value )
      if percentage = self.class.percentage( value )
        percentage = value.to_i
        self.class.percent_to_byte( percentage )
      else
        value.to_i if self.class.valid_byte?( value, true )
      end
    end     
  
    def render_as_given
      "rgb( #{self.red}, #{self.green}, #{self.blue} )"
    end  
  end
end  