require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Style = StyleTrain::Style unless defined?( Style )

describe Style do
  before :all do
    @selectors = [:p, :classy]
    @context = Style.new( :selectors =>['a.special'] )
  end
  
  describe 'level' do
    it 'is 0 by default' do
      Style.new(:selectors => @selectors).level.should == 0
    end
    
    it 'can be initialized to something else' do
      Style.new(:level => 3, :selectors => @selectors).level.should == 3
    end
  end
  
  describe 'selectors' do
    it 'makes the correct selectors' do
      Style.new(:selectors => @selectors).selectors.should == ['p', '.classy']
    end
    
    it 'takes into account the context' do
      Style.new(:selectors => @selectors, :context => @context).selectors.should == ['a.special p', 'a.special .classy']
    end
    
    it 'makes the correct selectors with the :concat option' do
      Style.new(:selectors => [:hover, :classy], :context => @context, :concat => :true).selectors.should == [
        'a.special:hover', 'a.special.classy'
      ]
    end
    
    it 'makes the correct selectors with the :child option' do
      Style.new(:selectors => [:bar, :p], :context => @context, :child => :true).selectors.should == [
        'a.special > .bar', 'a.special > p'
      ]
    end
    
    it 'concatenates psuedo selectors automatically' do
      Style.new(:selectors => [:hover, :classy], :context => @context).selectors.should == [
        'a.special:hover', 'a.special .classy'
      ]
    end
    
    it 'excludes tags when requested' do
      Style.selector(:p, :exclude_tags => :true)
    end
  end
  
  describe 'properties' do
    it 'is an empty array after initialization' do
      Style.new(:selectors => @selectors, :properties => ["some: thing;"]).properties.should == []
    end
    
    it 'adds property declarations' do
      style = Style.new(:selectors => @selectors)
      style.properties << "background-color: red"
      style.properties.size.should == 1
      style.properties.first.should == "background-color: red"
    end
  end
  
  describe 'rendering' do
    describe 'types' do
      before do
        @style = Style.new(:selectors => @selectors, :level => 2)
      end
      
      it 'renders full by default' do
        @style.properties << "foo:bar"
        @style.should_receive(:render_full)
        @style.render
      end
    
      it 'renders minimized if an argument is passed in' do
        @style.properties << "foo:bar"
        @style.should_receive(:render_linear)
        @style.render(:something_else)
      end
      
      it 'renders a commented line if the declaration is empty' do
        @style.render.should == "    /* p, .classy {} */"
      end
    end
    
    describe 'full' do
      before :all do
        style = Style.new(:selectors => @selectors)
        style.properties << 'background-color: yellow;' << 'color: maroon;'
        @first_level = style.render
        
        style = Style.new(:selectors => @selectors, :context => @context, :level => 3)
        style.properties << 'background-color: yellow;' << 'color: maroon;'
        @indented = style.render
      end
      
      it 'puts the selectors at the correct indent level on a new line' do
        @first_level.should match(/^p,/)
        @first_level.should match(/^\.classy/)
        
        @indented.should match(/^\W{6}a\.special p,/)
        @indented.should match(/^\W{6}a\.special \.classy/)
      end
      
      it 'brackets the properties' do
        @first_level.should match(/\{$/)
        @first_level.should match(/^\}/)
        
        @indented.should match(/\{$/)
        @indented.should match(/^\W{6}\}/)  
      end
      
      it 'puts each property on a new line' do
        @first_level.should match(/^\W*background-color: yellow;$/)
        @first_level.should match(/^\W*color: maroon;$/)
        
        @indented.should match(/^\W*background-color: yellow;$/)
        @indented.should match(/^\W*color: maroon;$/)
      end
      
      it 'puts the properties at the correct level' do
        @first_level.should match(/^\W{2}background/)
        @first_level.should match(/^\W{2}color/)
        
        @indented.should match(/^\W{8}background/)
        @indented.should match(/^\W{8}color/)
      end
    end
    
    describe 'linear' do
      before :all do
        style = Style.new(:selectors => @selectors)
        style.properties << 'background-color: yellow;' << 'color: maroon;'
        @first_level = style.render(:linear)
        
        style = Style.new(:selectors => @selectors, :context => @context, :level => 3)
        style.properties << 'background-color: yellow;' << 'color: maroon;'
        @indented = style.render(:linear)
        
        @properties = 'background-color: yellow; color: maroon;'
      end
      
      it 'puts the selectors at the correct indent level' do
        @first_level.should match(/\Ap,/)
        @indented.should match(/\A\W{6}a\.special p,/)
      end
      
      it 'separates the selectors with a comma and a space' do
        @first_level.should match /p, \.classy /
        @indented.should match /a\.special p, a\.special \.classy /
      end
      
      it 'separates the properties with a space' do
        @first_level.should include @properties
        @indented.should include @properties
      end
      
      it 'puts the bracketed properties on the same line as the selectors' do
        @first_level.should match /\Ap.*\}\z/
        @indented.should match /\A\W*a\.special.*\}\z/
      end
    end
  end 
end