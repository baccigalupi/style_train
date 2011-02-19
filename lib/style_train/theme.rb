module StyleTrain
  class Theme
    attr_accessor :value_hash, :name 
    
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
    
    def self.[](key)
      themes[key]
    end
    
    def self.keys
      themes.keys.map{|k| k.to_sym}
    end
    
    def initialize(name, value_hash)
      raise ArgumentError, "Unique name is required as first argument" if !name || self.class.themes[name]
      missing_keys = self.class.required_keys - value_hash.keys
      raise ArgumentError, "Required keys not provided: #{missing_keys.map{|k| k.inspect}.join(", ")}" if !missing_keys.empty?
      self.value_hash = Gnash.new(value_hash)
      self.name = name
      self.class.themes[name] = self
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