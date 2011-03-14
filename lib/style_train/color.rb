# This is a delegatory class that passes most everything to the particular ColorType descendant
module StyleTrain
  class Color
    attr_accessor :delegate, :background_set
   
    # Constructor 
    def initialize( color, opts={} ) 
      opts = Gnash.new(opts).merge(:color => color) 
      background_opts = opts.delete(:background) 
      self.background = background_opts if background_opts
      if color.is_a?(Color)
        self.delegate = color.delegate.dup
        self.alpha = opts[:alpha] if opts[:alpha]
        self.background = color.background if color.background_set
      else  
        color_types.each do |klass|
          if instance = klass.make(opts)
            self.delegate = instance
            break
          end
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
  
    def alpha=( value )
      self.delegate.alpha = value
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
      elsif opts.is_a? Color
        color = opts.dup # so that the original color's alpha isn't affected
        color.alpha = 1.0
        color
      else  
        Color.new(opts)
      end
      raise ArgumentError, "Background with color: #{color} and options: #{opts} not found" unless @background 
      raise ArgumentError, "Background color #{@background.inspect} has no delegate color" unless @background.delegate
    
      self.background_set = true
      @background  
    end
    
    def step(end_color, steps=10)
      start_color = self.delegate
      end_color = end_color.delegate
      array = [start_color]
      (2..(steps-1)).each do |number|
        ratio = 1 - (steps-number)/steps.to_f
        array << start_color.mix(end_color, ratio)
      end
      array << end_color
      array
    end
    
    def mix(color, ratio=0.5)
      Color.new(delegate.mix(self.class.colorize(color), ratio))
    end
    
    def +(color)
      mix(color)
    end
    
    def -(color)
      Color.new(self.class.colorize(color).mix(delegate))
    end
    
    def self.colorize(value)
      if value.is_a?(Color)
        value.delegate
      elsif color.is_a?(ColorType)
        value
      else
        Color.new(value)
      end
    end    
  
    def render(render_style=nil) 
      if render_style && render_style.to_sym == :ie
        self.background.to(:hex).layer(self.delegate).render
      else  
        self.delegate.render
      end   
    end
  
    def inspect 
      "<Color @delegate=#{self.delegate.to_s} @background=#{self.background}>"
    end  
  
    def to_s(render_style=nil)
      render(render_style)
    end      
  end
end 