# == Schema Information
# Schema version: 10
#
# Table name: descriptions
#
#  id            :integer(4)      not null, primary key
#  type          :string(255)     not null
#  person_id     :integer(4)      not null
#  mood_id       :integer(4)      not null
#  value         :integer(4)      not null
#  use_consensus :boolean(1)      not null
#  created_at    :datetime        
#  updated_at    :datetime        
#

# the value is an integer in RGB space
class Color < Description

  NEUTRAL = "#888888"
  
  def self.to_rgb(val)
    val.nil? ? NEUTRAL : "#%.6x" % val
  end

  def self.consensus(mood)
    all = mood.colors
    if all.empty?
      return nil
    else
      # all = Color.find(:all, :conditions => {:mood_id => mood.id})
      hue_sum = saturation_sum = lightness_sum = 0
      all.each_with_index do |color,i|
        hue_sum += color.hue
        saturation_sum += color.saturation
        lightness_sum += color.lightness
      end
      n = all.size
      from_hsl [hue_sum/n,saturation_sum/n,lightness_sum/n]
    end
  end

  def self.from_hsl(hsl_array)
    rgb_array = hsl_to_rgb(hsl_array)
    new(:value => 
      (rgb_array[0] * 0xFF).round * 0x010000 + 
      (rgb_array[1] * 0xFF).round * 0x000100 + 
      (rgb_array[2] * 0xFF).round
    )
  end
  
  def initialize(options = {})
    super(options)
    self.rgb = options[:rgb] if options[:rgb]
  end

  def min
    0
  end
  
  def max
    0xffffff
  end
  
  def rgb=(s)
    self.value = s.gsub(/^\#/, "0x").to_i(16)
  end
  
  def rgb
    Color.to_rgb(value)
  end

  def red
    (value / 0x10000) & 0xff
  end

  def green
    (value / 0x100) & 0xff
  end

  def blue
    (value) & 0xff
  end

  def hue
    hsl[0]
  end
  
  def saturation
    hsl[1]
  end
  
  def lightness
    hsl[2]
  end
  
  def contrast
    lightness < 0.5 ? "#ffffff" : '#000000'
  end

  # Various color utility functions stolen from Farbtastic and converted from JavaScript
  # Farbtastic was written by Steven Wittens and is licensed under the GPL.

  def hsl
    r = red/255.0
    g = green/255.0
    b = blue/255.0
    min = [r,g,b].min
    max = [r,g,b].max
    delta = max - min;
    l = (min + max) / 2;
    s = 0;
    if (l > 0 && l < 1)
      s = delta / (l < 0.5 ? (2 * l) : (2 - 2 * l));
    end
    h = 0;
    if (delta > 0)
      if (max == r && max != g) 
        h += (g - b) / delta;
      end
      if (max == g && max != b) 
        h += (2 + (b - r) / delta);
      end
      if (max == b && max != r) 
        h += (4 + (r - g) / delta);
      end
      h /= 6;
    end
    [h, s, l];
  end

  def self.hsl_to_rgb(hsl)
    h = hsl[0]
    s = hsl[1]
    l = hsl[2]
    m2 = (l <= 0.5) ? l * (s + 1) : l + s - l*s;
    m1 = l * 2 - m2;
    return [
      hue_to_rgb(m1, m2, h+0.33333),
      hue_to_rgb(m1, m2, h),
      hue_to_rgb(m1, m2, h-0.33333)
      ]
  end

  def self.hue_to_rgb(m1, m2, h)
    h = (h < 0) ? h + 1 : ((h > 1) ? h - 1 : h);
    if (h * 6 < 1) 
      return m1 + (m2 - m1) * h * 6;
    end
    if (h * 2 < 1) 
      return m2;
    end
    if (h * 3 < 2) 
      return m1 + (m2 - m1) * (0.66666 - h) * 6;
    end
    return m1;
  end

  NONE = Color.new(:rgb => NEUTRAL)
  
end
