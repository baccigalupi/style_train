class Fixnum
  ['px', 'em', 'pt', 'degrees'].each do |meth|
    class_eval <<-RUBY
      def #{meth}
        self.to_s + "#{meth}"
      end
    RUBY
  end
  
  def percent
    "#{self}%"
  end
end

class Float
  ['em', 'pt', 'degrees'].each do |meth|
    class_eval <<-RUBY
      def #{meth}
        self.to_s + "#{meth}"
      end
    RUBY
  end
  
  def percent
    "#{self}%"
  end
end