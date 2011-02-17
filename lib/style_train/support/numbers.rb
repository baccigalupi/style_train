class Fixnum
  def px
    "#{self}px"
  end
  
  def em
    "#{self}em"
  end
  
  def percent
    "#{self}%"
  end
  
  def pt
    "#{self}pt"
  end
end

class Float
  def em
    "#{self}em"
  end
end