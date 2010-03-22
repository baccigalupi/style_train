require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Color = StyleTrain::Color unless defined?(Color)
HexColor = StyleTrain::HexColor unless defined?( HexColor )
KeywordColor = StyleTrain::KeywordColor unless defined?( KeywordColor )
RGBcolor = StyleTrain::RGBcolor unless defined?( RGBcolor )

describe Color do
  before do
    #pending
  end
  
  def build_color( color_class, args ) 
    color_class.new(:color => args)
  end   
   
  describe 'initialization' do
    describe 'assigns a delegate' do
      describe 'with a keyword argument' do
        it 'should build an html keyword color' do
          Color.new("gray").delegate.should == build_color(KeywordColor, 'gray')
        end 

        it 'should build a svg keyword color' do 
          Color.new(:linen).delegate.should == build_color(KeywordColor, :linen)
        end
      end   
 
      describe 'with a hex string argument' do
        it '(3-digit no #) should build a hex color' do 
          Color.new('333').delegate.should == build_color(HexColor, '333')
        end
      
        it '(3-digit with #) should build a hex color' do 
          Color.new('#333').delegate.should == build_color(HexColor, '#333')
        end
      
        it '(6-digit no #) should build a hex color' do  
          Color.new('333333').delegate.should == build_color(HexColor, '333333')
        end
      
        it '(6-digit with #) should build a hex color' do
          Color.new('#333333').delegate.should == build_color(HexColor, '#333333')
        end
      end
 
      describe 'with an rgb array argument' do
        it '(with a byte array) should build a rgb color' do
          Color.new([127,127,127]).delegate.should == build_color(RGBcolor, [127,127,127])
        end
      
        it '(with a percentage array) should build a rgb color' do
          Color.new(['50%','50%','50%']).delegate.should == build_color(RGBcolor, [127,127,127])
        end
      end
    
      describe 'hsl colors' 
    end
    
    describe 'options' do
      it 'should pass on the alpha argument' do
        color = Color.new(:black, :alpha => 0.5)
        color.alpha.should == 0.5
      end
    end    
  end 
  
  describe 'comparison' do
    before do
      @color = Color.new(:black)
      @color_type = KeywordColor.new(:color => :black)
      @color_type_too = RGBcolor.new(:color => [0,0,0])
      @color_too = Color.new(:black)
    end
    
    describe '=~' do
      describe 'with another Color object' do
        it 'should not be true if the delegates don\'t match' do
          (@color =~ Color.new(:white)).should_not be_true  
        end
        
        it 'should be indifferent to background' do
          (@color =~ Color.new(:black, :background => :yellow)).should be_true
        end
        
        it 'should be true if background and delegate match' do
          (@color =~ @color_too).should be_true
        end
      end
      
      describe 'with a ColorType object' do
        it 'should be true if the delegate matches the ColorType' do
          (@color =~ @color_type).should be_true 
          (@color =~ @color_type_too).should be_true
        end
      end
    end  
    
    describe '==' do
      describe 'with another Color object' do
        it 'should not be true if the delegates don\'t match' do
          (@color == Color.new(:white)).should_not be_true  
        end
        
        it 'should be indifferent to background' do
          (@color == Color.new(:black, :background => :yellow)).should_not be_true
        end
        
        it 'should be true if background and delegate match' do
          (@color == @color_too).should be_true 
        end
      end
      
      describe 'with a ColorType object' do
        it 'should be false' do
          (@color == @color_type).should be_false
        end
      end
    end  
  end    

  describe 'background' do
    before do
      @color = Color.new(:black, :alpha => 0.5)
    end
    
    it 'should have a white opaque background by default' do
      @color.background.should =~ Color.new(:white)
    end 
    
    it 'should be settable' do
      @color.background = :black
      @color.background.should =~ Color.new(:black)
    end
    
    it 'should ignore alpha' do
      @color.background = {:color => :black, :alpha => 0.5 }
      @color.background.delegate.should == Color.new(:black, :alpha => 1.0).delegate
    end 
    
    it 'should be initalized into the instance' do
      color = Color.new(:black, :background => :yellow)
      color.background.should =~ Color.new(:yellow)
    end
  end
  
  describe 'rendering' do
    it 'should render via the delegates default method by default' do
      Color.new(:white).render.should == build_color(KeywordColor, :white).render_as_given
      Color.new(['100%', '100%', '100%']).render.should == build_color(RGBcolor, ['100%', '100%', '100%']).render_as_given
      Color.new([255,255,255]).render.should == build_color(RGBcolor, [255,255,255]).render_as_given
      Color.new('#FFF').render.should == build_color(HexColor, '#FFF').render_as_given
    end 
    
    it 'should render rgba if it has transparency' do  
      Color.new(:white, :alpha => 0.5).render.should =~ /rgba/
      Color.new(['100%', '100%', '100%'], :alpha => 0.5).render.should =~ /rgba/ 
      Color.new([255,255,255], :alpha => 0.5).render.should =~ /rgba/ 
      Color.new('#FFF', :alpha => 0.5).render.should =~ /rgba/ 
    end
    
    describe 'ie' do
      it 'should render default if there is no transparency' do 
        Color.new(:white).render(:ie).should == build_color(KeywordColor, :white).render_as_given
        Color.new(['100%', '100%', '100%']).render(:ie).should == build_color(RGBcolor, ['100%', '100%', '100%']).render_as_given
        Color.new([255,255,255]).render(:ie).should == build_color(RGBcolor, [255,255,255]).render_as_given
        Color.new('#FFF').render(:ie).should == build_color(HexColor, '#FFF').render_as_given 
      end 
      
      it 'should render delegate layered on opaque background if there is transparency' do
      end
    end
  end
end