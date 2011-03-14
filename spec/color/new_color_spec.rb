require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Color = StyleTrain::NewColor unless defined?(Color)
describe Color do
  describe 'initialization' do
    describe 'auto-detection' do
      it 'raises an error if autodetection fails' do
        lambda{ Color.new('ggg') }.should raise_error(Color::AutodetectionError)
      end
      
      describe 'transparent' do
        before :all do
          @trans = Color.new(:transparent)
          @trans_too = Color.new('transparent')
        end
      
        it 'has the type transparent' do
          @trans.type.should == @trans_too.type
          @trans.type.should == :transparent
        end
      
        it 'has r, g, b values of 0' do
          @trans.r.should == 0
          @trans.g.should == 0
          @trans.b.should == 0
        end
      
        it 'has an alpha of 0' do
          @trans.alpha.should == 0
        end
      
        it 'should ignore options, alpha, background, etc' do
          color = Color.new(:transparent, :alpha => 1.0, :background => '#666')
          color.alpha.should == 0
          color.background.should be_nil
        end
      end
    
      describe 'keyword colors' do
        it 'sets the type appropriately when passed a symbol' do
          Color.new(:lightyellow).type.should == :keyword
        end
      
        it 'raises an error if the symbol is not found' do
          lambda{ Color.new(:light_puke) }.should raise_error(
            Color::KeywordError, "Color :light_puke not found as a keyword"
          )
        end
      
        it 'should not raise an error if :transparent is given' do
          lambda{ Color.new(:transparent) }.should_not raise_error
        end
      
        it 'should set the r, g, and b values based on the key' do
          color = Color.new(:azure) 
          color.r.should == 240/255.0
          color.b.should == 1.0
          color.g.should == 1.0
        end
      end
    
      describe 'hexidecimal colors' do
        it 'sets the type to :hex' do
          Color.new('#666').type.should == :hex
          Color.new('#666666').type.should == :hex
        end
      
        it 'sets the hex_6' do
          Color.new('#444').hex_6.should == 0x444444
          Color.new('#404040').hex_6.should == 0x404040
        end
      
        it 'sets the rgb appropriately' do
          @gray = Color.new('#666')
          @red = Color.new('#993300') 
          @gold = Color.new('#FC0') 
        
          @gray.r.should == 102/255.0
          @red.r.should == 153/255.0
          @gold.r.should == 255/255.0
          
          @gray.g.should == 102/255.0
          @red.g.should == 51/255.0 
          @gold.g.should == 204/255.0     
          
          @gray.b.should == 102/255.0
          @red.b.should == 0   
          @gold.b.should == 0
        end
        
        it 'should pass of colors with many arguments' do
          lambda { Color.new('666', 100, 100) }.should raise_error(Color::AutodetectionError)
        end
      end
    
      describe 'rgb colors' do
        before do
          @color = Color.new(20,40,60)
        end
      
        it 'should set the type to :rgb' do
          @color.type.should == :rgb
        end
      
        it 'sets the rgb values appropriately' do
          @color.r.should == 20/255.0
          @color.g.should == 40/255.0
          @color.b.should == 60/255.0
        end
      
        it 'takes percentages if a string' do
          color = Color.new(0.percent, 50.percent, 100.percent)
          color.type.should == :rgb
          color.r.should == 0
          color.g.should == 0.5
          color.b.should == 1.0
        end
      
        it 'takes a ratio' do
          color = Color.new(0.0, 0.5, 1.0)
          color.type.should == :rgb
          color.r.should == 0
          color.g.should == 0.5
          color.b.should == 1.0
        end
      
        it 'raises an error if numbers are too large' do
          lambda{ Color.new(20, 300, 255) }.should raise_error(Color::ByteError)
        end
      
        it 'raises an error if the numbers are too small' do  
          lambda{ Color.new(20, 100, -155) }.should raise_error(Color::ByteError)
        end
      end
  
      describe 'hsl colors' do
        before do
          @color = Color.new( 350, 50.percent, 100.percent )
        end
      
        it 'correctly detects the type when first argument is greater than 255' do
          @color.type.should == :hsl
        end
      
        it 'takes ratios for s and l' do
          color = Color.new( 120.degrees, 0.0, 0.75 )
          color.type.should == :hsl
          color.h.should == 120.0/360
          color.s.should == 0
          color.l.should == 0.75
        end
      
        it 'sets the hsl correctly' do
          color = Color.new(0.degrees, 0.percent, 40.percent)
          color.h.should == 0
          color.s.should == 0
          color.l.should == 0.4
        end
      
        it 'converts to rgb correctly' do
          color = Color.new(0.degrees, 0.percent, 40.percent)
          color.r.should == 102/255.0 
          color.g.should == 102/255.0
          color.b.should == 102/255.0
        
          color = Color.new(210.degrees, 65.percent, 20.percent)
          color.r.should == 0.07
          color.g.should be_within(0.001).of(0.2)
          color.b.should == 0.33
        end
      end
    end
    
    describe 'explicit typing' do
      describe 'keyword' do
        it 'will raise an error if the keyword is not found' do
          lambda { Color.new(:light_puke, :type => :keyword) }.should raise_error(Color::KeywordError)
        end
      end
      
      describe 'hexidecimal colors' do
        it 'will convert a string without the preceeding #' do
          color = Color.new('666', :type => :hex )
          color.type.should == :hex
          color.r.should == 102/255.0
          color.g.should == 102/255.0
          color.b.should == 102/255.0
        end
        
        it 'raises an error if the string does not match hex color standards' do
          lambda{ Color.new('ggg', :type => :hex) }.should raise_error(ArgumentError)
        end
      end
      
      describe 'rgb colors' do
        it 'should work with good numbers' do
          color = Color.new(255,255,0, :type => :rgb)
          color.type.should == :rgb
          color.r.should == 1.0
          color.g.should == 1.0
          color.b.should == 0
        end
        
        it 'raises an error if any byte number is out of range' do
          lambda{ Color.new(300, 100, 100, :type => :rgb) }.should raise_error(ArgumentError)
        end
        
        it 'raises an error if any percentage is out of range' do
          lambda{ Color.new(300.percent, 100.percent, 100.percent, :type => :rgb) }.should raise_error(ArgumentError)
        end
        
        it 'raises an error if any ratio is out of range' do
          lambda{ Color.new(2.0, 1.0, 1.0, :type => :rgb) }.should raise_error(ArgumentError)
        end
      end
      
      describe 'hsl colors' do
        it 'will recognize the type even if hue is within byte range' do
          color = Color.new(220, 127, 127, :type => :hsl)
          color.type.should == :hsl
          color.r.should be_within(0.01).of(0.25)
          color.g.should be_within(0.01).of(0.416)
          color.b.should be_within(0.01).of(0.75)
        end
        
        it 'accepts ratios for hue' do
          color = Color.new(0.611111, 0.5, 0.5, :type => :hsl)
          color.type.should == :hsl
          color.r.should == 0.25
          color.g.should be_within(0.001).of(0.416)
          color.b.should == 0.75
        end
        
        it 'accepts percentages for hue' do
          color = Color.new(61.1111.percent, 50.percent, 50.percent, :type => :hsl)
          color.type.should == :hsl
          color.r.should == 0.25
          color.g.should be_within(0.001).of(0.416)
          color.b.should == 0.75
        end
      end
    end
  end
  
  describe 'normalizer' do
    describe 'percentages' do
      it 'should return valid integers' do
        Color.normalize_percentage(25.percent).should == 25
      end
      
      it 'should return valid floats' do
        Color.normalize_percentage(50.5.percent).should == 50.5
      end
      
      it 'works with an integer' do
        Color.normalize_percentage(50).should == 50
      end
      
      it 'works with floats' do
        Color.normalize_percentage(20.5).should == 20.5
      end
      
      it 'raises an error if greater than 100' do
        lambda{ Color.normalize_percentage(105) }.should raise_error(Color::PercentageError)
      end
      
      it 'raises an error if lower than 0' do
        lambda{ Color.normalize_percentage(-25) }.should raise_error(Color::PercentageError)
      end
      
      it 'converts to byte' do
        Color.percentage_to_byte(100.0).should == 255
        Color.percentage_to_byte(0).should == 0
        Color.percentage_to_byte(50.percent).should == 127
      end
    end
    
    describe 'degrees' do
      it 'should return a number between 0 and 359 when given such a number' do
        Color.normalize_degrees(42).should == 42/360.0
      end
      
      it 'should return a number when given a degree string' do
        Color.normalize_degrees(42.degrees).should == 42/360.0
      end
      
      it 'should return nil when given a string without degrees' do
        Color.normalize_degrees('42').should == nil
      end
      
      it 'should normalize a number greater than 359' do
        Color.normalize_degrees(360).should == 0
        Color.normalize_degrees(460).should == 100/360.0
      end
      
      it 'should normalize negative number' do
        Color.normalize_degrees(-127).should == 233/360.0
      end
      
      it 'works with strings containing "degrees"' do
        Color.normalize_degrees(127.degrees).should == 127/360.0
      end
      
      it 'rejects percentage strings' do
        Color.normalize_degrees(12.percent).should == nil
      end
    end
    
    describe 'ratios' do
      it 'raises an error if below 0' do
        lambda{ Color.ratio_to_byte(-0.1) }.should raise_error(Color::RatioError)
      end
      
      it 'raises an error if it is above 1.0' do
        lambda{ Color.ratio_to_byte(1.1)}.should raise_error(Color::RatioError)
      end
      
      it 'converts correctly to byte otherwise' do
        Color.ratio_to_byte(0.5).should == 127
      end
    end
  end

  describe 'mixing' do
    
  end
end