# This is a delegator class that passes everything to the particular ColorType descendant
class Color 
  
  # def self.make( color, opts={} ) 
  #   opts = Gnash.new( opts ).merge!(:color => color)
  #   if [String, Symbol].include?( color.class )
  #     if color.match(/^#/) || [3,6].include?( color.to_s.to_i.size )
  #       super( opts.merge( :init_type => :hex ) )
  #     else 
  #       super( opts.merge( :init_type => :keyword ) )
  #     end     
  #   elsif color.class == Array
  #     if opts[:hsl]
  #       super( opts.merge( :init_type => :hsl ) )
  #     else
  #       super( opts.merge( :init_type => :rgb ) )
  #     end    
  #   else
  #     raise ArgumentError, 'Not a valid class for a color. It should be an Array, String, Symbol or Fixnum'  
  #   end      
  # end 
       
end 