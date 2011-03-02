module StyleTrain
  class Style
    attr_accessor :selectors, :level, :properties, :opts
    
    def initialize(opts)
      self.opts = opts
      self.level = opts[:level].to_i
      self.selectors = []
      self.properties = []
      set_selectors opts[:selectors], opts[:context] && opts[:context].selectors
    end
    
    def spacing(value)
      PSUEDOS.include?(value) || opts[:concat] ? '' : ' '
    end
    
    def set_selectors values, contexts
      if contexts
        contexts.each do |context|
          values.each do |value|
            self.selectors << "#{context}#{spacing(value)}#{make_selector(value)}"
          end
        end
      else
        values.each do |value|
          self.selectors << make_selector(value)
        end
      end
    end
    
    TAGS = [
      :a, :abbr, :acronym, :address, :area, :b, :base, :bdo, 
      :big, :blockquote, :body, :br, :button, :caption, :center, 
      :cite, :code, :col, :colgroup, :dd, :del, :dfn, :div, 
      :dl, :dt, :em, :embed, :fieldset, :form, :frame, :frameset, 
      :h1, :h2, :h3, :h4, :h5, :h6, :head, :hr, :html, :i, :iframe, 
      :img, :input, :ins, :kbd, :label, :legend, :li, :link, 
      :map, :meta, :noframes, :noscript, :object, :ol, :optgroup, 
      :option, :p, :param, :pre, :q, :s, :samp, :script, :select, 
      :small, :span, :strike, :strong, :sub, :sup, :table, 
      :tbody, :td, :textarea, :tfoot, :th, :thead, :title, 
      :tr, :tt, :u, :ul, :var
    ]
    
    PSUEDOS = [
      :link, :visited, :hover, :active, :target, :before, :after, 
      :enabled, :disabled, :checked, :focus
    ]
    
    def make_selector(value)
      self.class.selector(value, opts)
    end
    
    def self.selector(value, opts={})
      value = if value.is_a?(String) || (!opts[:exclude_tags] && TAGS.include?(value))
        value.to_s 
      elsif PSUEDOS.include?(value)
        ":#{value}"
      else
        ".#{value}"
      end
      opts[:child] ? "> #{value}" : value
    end
    
    INDENT = '  '
    
    def render(type=:full)
      if properties.empty?
        render_empty
      elsif type == :full
        render_full
      else
        render_linear
      end
    end
    
    alias :to_s :render
    
    def render_empty
      "#{indent}/* #{selectors.join(', ')} {} */"
    end
    
    def render_full
      str = ""
      
      # selectors
      array = selectors.dup
      last_selector = array.pop
      array.each do |selector|
        str << "#{indent}#{selector},\n"
      end
      str << "#{indent}#{last_selector} {" 
      
      # properties
      properties.each do |property|
        str << "\n#{indent(1)}#{property}"
      end
      str << "\n#{indent}}"
      
      str 
    end
    
    def render_linear
      str = "#{indent}"
      str << selectors.join(', ')
      str << " { "
      str << properties.join(' ')
      str << " }"
    end
    
    def indent(plus=0)
      INDENT * (level+plus)
    end
  end
end