class Contexting
  attr_accessor :context, :last_context
  
  def style(*selectors)
    self.last_context = context
    self.context = Style.new(selectors)
    yield if block_given?
    self.context = last_context
  end
  
  def render
    style(:outer) {
      puts context
      style(:inner){
        puts context
      }
      puts context
    }
  end
end

class Style
  attr_accessor :selectors
  
  def initialize(selectors)
    self.selectors = selectors
  end
  
  def to_s
    "<Style selectors=#{selectors.inspect}>"
  end
end

Contexting.new.render