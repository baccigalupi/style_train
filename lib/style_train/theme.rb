module StyleTrain
  class Theme
    attr_accessor :value_hash, :name, :palette 
    
    def self.required_keys *args
      if args.empty?
        @required_keys ||= []
      else
        @required_keys = args.map{ |v| v.to_sym }
      end
    end
    
    def self.themes
      @themes ||= Gnash.new
    end
    
    def self.defaults hash=nil
      if hash
        @defaults = Gnash.new(hash)
      else
        @defaults || Gnash.new
      end
    end
    
    def self.[](key)
      themes[key]
    end
    
    def self.keys
      themes.keys.map{|k| k.to_sym}
    end
    
    def initialize(name, value_hash, palette = {})
      raise ArgumentError, "Unique name is required as first argument" if !name || self.class.themes[name]
      self.palette = palette
      self.value_hash = Gnash.new(self.class.defaults.merge(substitute(value_hash)))
      missing_keys = self.class.required_keys - self.value_hash.keys.map{|k| k.to_sym}
      raise ArgumentError, "Required keys not provided: #{missing_keys.map{|k| k.inspect}.join(", ")}" if !missing_keys.empty?
      self.name = name
      self.class.themes[name] = self
    end
    
    def substitute hash
      hash.each do |key, value|
        hash[key] = palette[value] if palette[value]
      end
      hash
    end
    
    def [](key)
      value_hash[key]
    end
    
    def []=(key, value)
      if (value.nil? || value.to_s.empty?) && self.class.required_keys.include?(key.to_sym)
        raise "Cannot set a required key to nothing"
      end
      value_hash[key] = value
    end
  end
end