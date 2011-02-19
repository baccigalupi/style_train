module StyleTrain
  class ThemedSheet < Sheet
    def self.themes(klass=nil)
      if klass
        if !klass.ancestors.include?(StyleTrain::Theme)
          raise ArgumentError, "themes must be a StyleTrain::Theme class"
        end
        @themes = klass
      else
        raise ArgumentError, "No themes class is defined. Please add one with the class method #themes" unless @themes
        @themes
      end
    end
    
    def theme
      @theme || self.class.themes[:default] || raise( "No theme has been set" )
    end
    
    def theme=(key)
      (@theme = self.class.themes[key]) || raise( ArgumentError, "Theme #{key.inspect} not found in #{self.class.themes}")
    end
    
    def self.export
      sheet = new
      themes.keys.each do |key|
        sheet.theme = key
        sheet.export
      end
    end
    
    def file_name name=nil
      (name || self.class.to_s.underscore) + "_#{theme.name.to_s.underscore}"
    end
  end
end