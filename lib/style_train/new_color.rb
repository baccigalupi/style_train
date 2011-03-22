module StyleTrain
  class NewColor
    attr_accessor :type, :r, :g, :b, 
      :hex, :hex_6, :h, :s, :l
    attr_reader :alpha 
    
    def initialize(*args)
      if type = args.last.is_a?(Hash) && args.last[:type]
        build_for_type(type, args)
      else
        autodetect(args)
      end
      
      if non_null?
        if (opts = args.last) && args.last.is_a?(Hash)
          self.alpha = opts[:alpha]
          self.background = opts[:background] if opts[:background]
        end
      end
      self.alpha = 1.0 if alpha.nil? && non_null?
    end
    
    def transparent?
      type == :transparent
    end
    
    def non_null?
      !transparent?
    end
    
    def build_for_type(type, args)
      self.type = type
      color = if type == :transparent
        build_transparent(args)
      elsif type == :keyword
        build_keyword(args)
      elsif type == :hex
        build_hex(args)
      elsif type == :rgb
        build_rgb(args)
      elsif type == :hsl
        build_hsl(args)
      end
      raise ArgumentError, "Unable to build a color of type #{type}, with arguments: #{args.inspect}" unless color
    end
    
    def autodetect(args)
      build_transparent(args) ||
      build_keyword(args) ||
      build_hex(args) ||
      build_rgb(args) ||
      build_hsl(args) || raise( AutodetectionError )
    end
    
    def build_transparent( args )
      if [:transparent, 'transparent'].include?(args.first)
        self.type = :transparent
        self.r = self.g = self.b = 0
        self.alpha = 0.0
        self
      end 
    end
    
    def build_keyword( args )
      if (color = args.first).is_a?(Symbol)
        self.type = :keyword
        raise KeywordError, "Color #{color.inspect} not found as a keyword" unless rgb = KEYWORD_MAP[color]
        self.r = rgb[0]/255.0
        self.g = rgb[1]/255.0
        self.b = rgb[2]/255.0
        self 
      end
    end
    
    def build_hex(args)
      if args.size < 3 && args.first.to_s.match(/^#?([a-f0-9]{3}|[a-f0-9]{6})$/i)
        self.type = :hex
        self.hex = "#{$1}"
        self.hex_6 = self.class.normalize_hex(hex)
        self.r = ((self.hex_6 / 0x10000) & 0xff) / 255.0
        self.g = ((self.hex_6 / 0x100) & 0xff) / 255.0
        self.b = (self.hex_6  & 0xff) /255.0
        self
      end
    end
    
    def build_rgb(args)
      array = args[0..2].compact
      first_value = self.class.normalize_for_rgb(array.first) rescue nil
      return nil unless array.size == 3 && first_value
      
      self.type = :rgb
      self.r = first_value
      self.g = self.class.normalize_for_rgb(array[1])
      self.b = self.class.normalize_for_rgb(array[2])
      self
    end
    
    def build_hsl(args)
      array = args[0..2].compact
      hue = self.class.normalize_hue(array.first) rescue nil
      return nil unless array.size == 3 && hue
      
      self.type = :hsl
      self.h = hue
      self.s = self.class.normalize_for_hsl(array[1])
      self.l = self.class.normalize_for_hsl(array[2])
      build_rgb_from_hsl
      
      self
    end
    
    def self.normalize_hue(value)
      if value.is_a?(String) 
        if value.match(/degrees$/)
          normalize_degrees(value)
        else 
          normalize_percentage(value) / 100.0
        end
      elsif value.is_a?(Float)
        normalize_ratio(value)
      else
        normalize_degrees(value) # hue does not come it byte values
      end
    end
    
    def self.normalize_for_hsl(value)
      if value.is_a?(String)
        normalize_percentage(value)/100.0 if value.match(/%$/)
      elsif value.is_a?(Float)
        normalize_ratio(value)
      else # integer
        normalize_byte(value)/255.0
      end
    end
    
    def build_rgb_from_hsl
      self.r = hsl_value_to_rgb( h + 1/3.0 )
      self.g = hsl_value_to_rgb( h )
      self.b = hsl_value_to_rgb( h - 1/3.0 )
    end
    
    def hsl_value_to_rgb( value=[h,s,l] )
      value = value + 1 if value < 0 
      value = value - 1 if value > 1
      if value * 6 < 1
        hsl_median_1 + (hsl_median_2 - hsl_median_1)*value*6 
      elsif value * 2 < 1
        hsl_median_2
      elsif value * 3 < 2
        hsl_median_1 + (hsl_median_2 - hsl_median_1)*(2/3.0 - value)*6
      else
        hsl_median_1
      end
    end
    
    def hsl_median_2
      l <= 0.5 ? l*(s+1) : l+s-l*s
    end
    
    def hsl_median_1
      l*2-hsl_median_2
    end
    
    # CLASS LEVEL VALUE NORMALIZERS -----------------------------------------------
    def self.normalize_for_rgb(value)
      if value.is_a?(String)
        if value.match(percentage_regex)
          normalize_percentage(value)/100.0
        elsif value.match(degree_regex)
          return nil
        else
          normalize_byte(value)/255.0
        end
      elsif value.is_a?(Float)
        normalize_ratio(value)
      else # integer
        normalize_byte(value)/255.0
      end
    end
    
    def self.normalize_percentage(value)
      if value.class == String && value.match(percentage_regex)
        value = $1
      end
      value = value.to_f
      raise PercentageError  if value > 100.0 || value < 0.0 
      value
    end
    
    def self.percentage_regex
      /^([\d.]*)%$/
    end
    
    def self.normalize_degrees(value)
      return nil if value.is_a?(String) && !value.match(degree_regex)
      (value.to_i % 360)/360.0
    end
    
    def self.degree_regex
      /degrees$/
    end
    
    def self.normalize_byte(value)
      raise ByteError  if value > 255 || value < 0
      value
    end
    
    def self.normalize_ratio(value)
      raise RatioError if value > 1 || value < 0
      value
    end
    
    def self.ratio_to_byte(value)
      raise RatioError if value < 0 || value > 1.0
      percentage_to_byte(value*100)
    end
    
    def self.normalize_hex( hex ) 
      expanded = ""
      if hex.size == 3
        hex.each_char{|c| expanded << c*2}
      else
        expanded = hex
      end
      
      "0x#{expanded}".to_i(16)       
    end
    
    def self.percentage_to_byte(value)
      (normalize_percentage(value) * 2.55 ).round
    end
    
    # OPTIONAL PROPERTIES ----------------------------------------------
    def alpha=(value)
      if value
        @alpha = if value.is_a?(String) || value.is_a?(Fixnum)
          self.class.normalize_percentage(value)/100.0
        else
          self.class.normalize_ratio(value)
        end
      end
    end
    
    def background=(value)
      @background = if value.is_a?(self.class)
        value
      else
        self.class.new(*value)
      end
    end
    
    def background
      @background || self.class.new(:white) unless type == :transparent
    end
    
    # COMPARITORS ------------------------------------------------------
    COMPARE_TOLERANCE = 0.001
    
    def ==(other)
      self =~ other &&
      self.alpha == other.alpha
    end
    
    def ===(other)
      self.object_id == other.object_id
    end
    
    def =~(other)
      (self.r - other.r).abs < COMPARE_TOLERANCE &&
      (self.g - other.g).abs < COMPARE_TOLERANCE&&
      (self.b - other.b).abs < COMPARE_TOLERANCE
    end
    
    # CONVERSIONS ------------------------------------------------------
    def set_hsl
      rgb = [r, g, b]
      max = rgb.max 
      min = rgb.min
      avg = ( max + min )/2.0
      diff = ( max - min ).to_f
      lightness = avg
      
      if max == min  # achromatic
        hue = 0
        saturation = 0
      else
        saturation = if avg > 0.6
          lightness / ( 2 - max - min )
        else
          diff / ( max + min )
        end
        
        diff_r = (((max - r) / 6) + (diff / 2)) / diff;
        diff_g = (((max - g) / 6) + (diff / 2)) / diff;
        diff_b = (((max - b) / 6) + (diff / 2)) / diff;
        
        hue = if r == max
          diff_b - diff_g
        elsif g == max
          1/3.0 + diff_r - diff_b
        else
          2/3.0 + diff_g - diff_r
        end
      end
      
      
      hue += 1 if hue < 0
      hue -= 1 if hue > 1

      self.type = :hsl
      self.h = hue
      self.s = saturation
      self.l = lightness
      
      self
    end
    
    def set_rgb
      self.type = :rgb
    end
    
    def set_hex
      self.type = :hex
      self.hex = ""
      self.hex << sprintf( "%02X", r*255 );
      self.hex << sprintf( "%02X", g*255 );
      self.hex << sprintf( "%02X", b*255 );
      self.hex_6 = self.class.normalize_hex(hex)
    end
    
    def hsl_to_rgb
      self.hex = nil
      self.hex_6 = nil
      build_rgb_from_hsl
      self
    end
    
    # transformations
    def reset_for_shift
      self.hex = nil
      self.hex_6 = nil
      set_hsl unless :type == :hsl
    end
    
    def shift!(value)
      reset_for_shift
      value = value/100.0 if value.is_a?(Integer)
      value = self.class.normalize_percentage(value)/100.0 if value.is_a?(String)
      value = self.class.normalize_ratio(value) 
      yield(value)
      hsl_to_rgb
    end
    
    def lighten(value=0.1)
      color = self.dup
      color.lighten!(value)
    end
    
    def lighten!(value=0.1)
      shift!(value) {|v| self.l = [1.0, l + v].min }
    end
    
    def darken(value=0.1)
      color = self.dup
      color.darken!(value)
    end
    
    def darken!(value=0.1)
      shift!(value) { |v| self.l = [0.0, l - v].max }
    end
    
    def saturate(value=0.1)
      color = self.dup
      color.saturate!(value)
    end
    
    def saturate!(value=0.1)
      shift!(value) { |v| self.s = [1.0, s + v].min }
    end
    
    def dull(value=0.1)
      color = self.dup
      color.dull!(value)
    end
    
    def dull!(value=0.1)
      shift!(value) { |v| self.s = [0.0, s - v].max }
    end
    
    alias :brighten :saturate
    alias :brighten! :saturate!
    alias :desaturate :dull
    alias :desaturate! :dull!
    
    def shift_hue!(value)
      reset_for_shift
      value = self.class.normalize_hue(value)
      yield(value)
      hsl_to_rgb
    end
    
    def rotate(value=10.degrees)
      color = self.dup
      color.rotate!(value)
    end
    
    def rotate!(value=10.degrees)
      shift_hue!(value) {|v| self.h = (v + h) % 1 }
    end
    
    def compliment
      rotate(0.5)
    end
    
    def dial(divisions=3, offset = 0.0)
      divisions = divisions.to_i
      offset = self.class.normalize_hue(offset)
      set = []
      (1..divisions).each do |n|
        amount = (offset + (n-1)/divisions.to_f)%1
        set << rotate(amount)
      end
      set
    end
    
    def triangulate(offset = 0.0)
      dial(3, offset)
    end
    
    COLDEST_HUE = 240/360.0
    WARMEST_HUE = 0.0
    
    def warmer(value=10.degrees)
      set_hsl
      value = self.class.normalize_hue(value)
      color = self.dup
      unless [COLDEST_HUE, WARMEST_HUE].include?(h)
        new_h = if h < COLDEST_HUE
          [WARMEST_HUE, (h - value)].max.abs
        else
          [1.0-WARMEST_HUE, (h + value)].min.abs
        end
        color.rotate!((new_h - h)%1)
      end
      color
    end
    
    KEYWORD_MAP = {
      :aliceblue	=>	[240, 248, 255],
   	 	:antiquewhite	=>	[250, 235, 215],
   	 	:aqua	=>	[0, 255, 255],
   	 	:aquamarine	=>	[127, 255, 212],
   	 	:azure	=>	[240, 255, 255],
   	 	:beige	=>	[245, 245, 220],
   	 	:bisque	=>	[255, 228, 196],
   	 	:black	=>	[0, 0, 0],
   	 	:blanchedalmond	=>	[255, 235, 205],
   	 	:blue	=>	[0, 0, 255],
   	 	:blueviolet	=>	[138, 43, 226],
   	 	:brown	=>	[165, 42, 42],
   	 	:burlywood	=>	[222, 184, 135],
   	 	:cadetblue	=>	[95, 158, 160],
   	 	:chartreuse	=>	[127, 255, 0],
   	 	:chocolate	=>	[210, 105, 30],
   	 	:coral	=>	[255, 127, 80],
   	 	:cornflowerblue	=>	[100, 149, 237],
   	 	:cornsilk	=>	[255, 248, 220],
   	 	:crimson	=>	[220, 20, 60],
   	 	:cyan	=>	[0, 255, 255],
   	 	:darkblue	=>	[0, 0, 139],
   	 	:darkcyan	=>	[0, 139, 139],
   	 	:darkgoldenrod	=>	[184, 134, 11],
   	 	:darkgray	=>	[169, 169, 169],
   	 	:darkgreen	=>	[0, 100, 0],
   	 	:darkgrey	=>	[169, 169, 169],
   	 	:darkkhaki	=>	[189, 183, 107],
   	 	:darkmagenta	=>	[139, 0, 139],
   	 	:darkolivegreen	=>	[85, 107, 47],
   	 	:darkorange	=>	[255, 140, 0],
   	 	:darkorchid	=>	[153, 50, 204],
   	 	:darkred	=>	[139, 0, 0],
   	 	:darksalmon	=>	[233, 150, 122],
   	 	:darkseagreen	=>	[143, 188, 143],
   	 	:darkslateblue	=>	[72, 61, 139],
   	 	:darkslategray	=>	[47, 79, 79],
   	 	:darkslategrey	=>	[47, 79, 79],
   	 	:darkturquoise	=>	[0, 206, 209],
   	 	:darkviolet	=>	[148, 0, 211],
   	 	:deeppink	=>	[255, 20, 147],
   	 	:deepskyblue	=>	[0, 191, 255],
   	 	:dimgray	=>	[105, 105, 105],
   	 	:dimgrey	=>	[105, 105, 105],
   	 	:dodgerblue	=>	[30, 144, 255],
   	 	:firebrick	=>	[178, 34, 34],
   	 	:floralwhite	=>	[255, 250, 240],
   	 	:forestgreen	=>	[34, 139, 34],
   	 	:fuchsia	=>	[255, 0, 255],
   	 	:gainsboro	=>	[220, 220, 220],
   	 	:ghostwhite	=>	[248, 248, 255],
   	 	:gold	=>	[255, 215, 0],
   	 	:goldenrod	=>	[218, 165, 32],
   	 	:gray	=>	[128, 128, 128],
   	 	:green	=>	[0, 128, 0],
   	 	:greenyellow	=>	[173, 255, 47],
   	 	:grey	=>	[128, 128, 128],
   	 	:honeydew	=>	[240, 255, 240],
   	 	:hotpink	=>	[255, 105, 180],
   	 	:indianred	=>	[205, 92, 92],
   	 	:indigo	=>	[75, 0, 130],
   	 	:ivory	=>	[255, 255, 240],
   	 	:khaki	=>	[240, 230, 140],
   	 	:lavender	=>	[230, 230, 250],
   	 	:lavenderblush	=>	[255, 240, 245],
   	 	:lawngreen	=>	[124, 252, 0],
   	 	:lemonchiffon	=>	[255, 250, 205],
   	 	:lightblue	=>	[173, 216, 230],
   	 	:lightcoral	=>	[240, 128, 128],
   	 	:lightcyan	=>	[224, 255, 255],
   	 	:lightgoldenrodyellow	=>	[250, 250, 210],
   	 	:lightgray	=>	[211, 211, 211],
   	 	:lightgreen	=>	[144, 238, 144],
   	 	:lightgrey	=>	[211, 211, 211],
   	 	:lightpink	=>	[255, 182, 193],
   	 	:lightsalmon	=>	[255, 160, 122],
   	 	:lightseagreen	=>	[32, 178, 170],
   	 	:lightskyblue	=>	[135, 206, 250],
   	 	:lightslategray	=>	[119, 136, 153],
   	 	:lightslategrey	=>	[119, 136, 153],
   	 	:lightsteelblue	=>	[176, 196, 222],
   	 	:lightyellow	=>	[255, 255, 224],
   	 	:lime	=>	[0, 255, 0],
   	 	:limegreen	=>	[50, 205, 50],
   	 	:linen	=>	[250, 240, 230],
   	 	:magenta	=>	[255, 0, 255],
   	 	:maroon	=>	[128, 0, 0],
   	 	:mediumaquamarine	=>	[102, 205, 170],
   	 	:mediumblue	=>	[0, 0, 205],
   	 	:mediumorchid	=>	[186, 85, 211],
   	 	:mediumpurple	=>	[147, 112, 219],
   	 	:mediumseagreen	=>	[60, 179, 113],
   	 	:mediumslateblue	=>	[123, 104, 238],
   	 	:mediumspringgreen	=>	[0, 250, 154],
   	 	:mediumturquoise	=>	[72, 209, 204],
   	 	:mediumvioletred	=>	[199, 21, 133],
   	 	:midnightblue	=>	[25, 25, 112],
   	 	:mintcream	=>	[245, 255, 250],
   	 	:mistyrose	=>	[255, 228, 225],
   	 	:moccasin	=>	[255, 228, 181],
   	 	:navajowhite	=>	[255, 222, 173],
   	 	:navy	=>	[0, 0, 128],
   	 	:oldlace	=>	[253, 245, 230],
   	 	:olive	=>	[128, 128, 0],
   	 	:olivedrab	=>	[107, 142, 35],
   	 	:orange	=>	[255, 165, 0],
   	 	:orangered	=>	[255, 69, 0],
   	 	:orchid	=>	[218, 112, 214],
   	 	:palegoldenrod	=>	[238, 232, 170],
   	 	:palegreen	=>	[152, 251, 152],
   	 	:paleturquoise	=>	[175, 238, 238],
   	 	:palevioletred	=>	[219, 112, 147],
   	 	:papayawhip	=>	[255, 239, 213],
   	 	:peachpuff	=>	[255, 218, 185],
   	 	:peru	=>	[205, 133, 63],
   	 	:pink	=>	[255, 192, 203],
   	 	:plum	=>	[221, 160, 221],
   	 	:powderblue	=>	[176, 224, 230],
   	 	:purple	=>	[128, 0, 128],
   	 	:red	=>	[255, 0, 0],
   	 	:rosybrown	=>	[188, 143, 143],
   	 	:royalblue	=>	[65, 105, 225],
   	 	:saddlebrown	=>	[139, 69, 19],
   	 	:salmon	=>	[250, 128, 114],
   	 	:sandybrown	=>	[244, 164, 96],
   	 	:seagreen	=>	[46, 139, 87],
   	 	:seashell	=>	[255, 245, 238],
   	 	:sienna	=>	[160, 82, 45],
   	 	:silver	=>	[192, 192, 192],
   	 	:skyblue	=>	[135, 206, 235],
   	 	:slateblue	=>	[106, 90, 205],
   	 	:slategray	=>	[112, 128, 144],
   	 	:slategrey	=>	[112, 128, 144],
   	 	:snow	=>	[255, 250, 250],
   	 	:springgreen	=>	[0, 255, 127],
   	 	:steelblue	=>	[70, 130, 180],
   	 	:tan	=>	[210, 180, 140],
   	 	:teal	=>	[0, 128, 128],
   	 	:thistle	=>	[216, 191, 216],
   	 	:tomato	=>	[255, 99, 71],
   	 	:turquoise	=>	[64, 224, 208],
   	 	:violet	=>	[238, 130, 238],
   	 	:wheat	=>	[245, 222, 179],
   	 	:white	=>	[255, 255, 255],
   	 	:whitesmoke	=>	[245, 245, 245],
   	 	:yellow	=>	[255, 255, 0],
   	 	:yellowgreen	=>	[154, 205, 50]
   }
   
   class PercentageError < ArgumentError
     def message 
       @message ||= 'Percentages must be between 0 and 100'
     end
   end 
   
   class KeywordError < ArgumentError; end
   
   class RatioError < ArgumentError
     def message
       @message ||= "Ratios must be a decimal value between 0 and 1"
     end
   end
   
   class ByteError < ArgumentError
     def message
       @message ||= "Bytes must be between 0 and 255"
     end
   end
   
   class AutodetectionError < ArgumentError
     def message
       @message ||= "Unable to determine color type"
     end
   end
  end
end