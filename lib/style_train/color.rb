# This is a delegatory class that passes most everything to the particular ColorType descendant
class Color
  attr_accessor :delegate
   
  # Constructor 
  def initialize( color, opts={} ) 
    opts = Gnash.new(opts).merge(:color => color) 
    background_opts = opts.delete(:background) 
    self.background = background_opts if background_opts
    color_types.each do |klass|
      if instance = klass.make(opts)
        self.delegate = instance
        break
      end
    end    
  end 
  
  def self.color_types
    @color_type ||= ColorType.color_types
  end 
  
  def color_types
    self.class.color_types
  end
  
  # delegated methods
  [:alpha, :r, :g, :b].each do |meth|
    class_eval "
      def #{meth}
        self.delegate.#{meth}
      end
    "
  end
  
  def to(key)
    self.delegate.to(key)
  end 
  
  def =~( color )
    if color.is_a?(Color)
      self.delegate =~ color.delegate
    elsif color.is_a?( ColorType )
      self.delegate =~ color
    end    
  end 
  
  def ==( color )
    color.is_a?( Color ) && self =~ color && self.background == color.background
  end    
    
  # rendering
  def background
    @background ||= Color.new(:white).to(:hex)
  end 
  
  def background=( opts )
    color = opts.is_a?(Hash) && (opts[:color] || opts['color'])
    @background = if color 
      opts.delete(:alpha)
      Color.new(color, opts)  
    else
      Color.new(opts)
    end  
  end
  
  def render(render_style=nil)
    self.delegate.render 
  end    

end 