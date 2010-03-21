class RGBcolor < ColorType
  attr_accessor :red, :green, :blue # these are the entered values, not the calculated values 
  
  def type_initialize( color, opts )
    if color.class.ancestors.include?( ColorType )
      # build from r, g, b
    elsif color.class == Array  
      self.red =    color[0]
      self.green =  color[1]
      self.blue =   color[2] 
    else
      raise ArgumentError, 'RGB color must be initialized with a :color opts argument that is an array' unless color && color.class == Array
    end  
  end
  
  ['red', 'green', 'blue'].each do |clr|
    class_eval " 
      def #{clr}=( value )
        @#{clr} = value
        self.#{clr[0..0]} = normalize_internal_rgb( value )  
      end 
    "
  end  
  
  def normalize_internal_rgb( value )
    if percentage = self.class.percentage( value )
      percentage = value.to_i
      self.class.percent_to_byte( percentage )
    else
      value.to_i if self.class.valid_byte?( value, true )
    end
  end     
  
  def to_s
    "rgba( #{self.red}, #{self.green}, #{self.blue}, #{self.alpha} )"
  end  
end  