require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Color = StyleTrain::NewColor unless defined?(Color)
describe Color do
  TOLERANCE = 0.009
  
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
          color.type.should == :transparent
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
          color.g.should be_within(TOLERANCE).of(0.2)
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
          color.r.should be_within(TOLERANCE).of(0.25)
          color.g.should be_within(TOLERANCE).of(0.416)
          color.b.should be_within(TOLERANCE).of(0.75)
        end
        
        it 'accepts ratios for hue' do
          color = Color.new(0.611111, 0.5, 0.5, :type => :hsl)
          color.type.should == :hsl
          color.r.should == 0.25
          color.g.should be_within(TOLERANCE).of(0.416)
          color.b.should == 0.75
        end
        
        it 'accepts percentages for hue' do
          color = Color.new(61.1111.percent, 50.percent, 50.percent, :type => :hsl)
          color.type.should == :hsl
          color.r.should == 0.25
          color.g.should be_within(TOLERANCE).of(0.416)
          color.b.should == 0.75
        end
      end
    end
  
    describe 'alpha' do
      describe 'autodetection' do
        it 'ignores the alpha with a transparent color' do
          Color.new(:transparent, :alpha => 0.5).alpha.should == 0.0
        end
        
        it 'sets the alpha with a keyword type' do
          Color.new(:lightyellow, :alpha => 0.5).alpha.should == 0.5
        end
        
        it 'sets the alpha with a hex color' do
          Color.new('#666', :alpha => 0.75).alpha.should == 0.75
        end
        
        it 'sets the alpha with a rgb color' do
          Color.new(100.percent, 50.percent, 25.percent, :alpha => 0.25).alpha.should == 0.25
        end
        
        it 'sets the alpha with a hsl color' do
          Color.new(20.degrees, 50.percent, 50.percent, :alpha => 0.10).alpha.should == 0.1
        end
        
        it 'sets the alpha to 1.0 by default' do
          Color.new(:lightyellow).alpha.should == 1.0
        end
      end
      
      describe 'explicit typing' do
        it 'ignores the alpha with a transparent color' do
          Color.new(:transparent, :alpha => 0.5, :type => :transparent).alpha.should == 0.0
        end
        
        it 'sets the alpha with a keyword type' do
          Color.new(:lightyellow, :type => :keyword, :alpha => 0.5).alpha.should == 0.5
        end
        
        it 'sets the alpha with a hex color' do
          Color.new('#123456', :type => :hex, :alpha => 0.25).alpha.should == 0.25
        end
        
        it 'sets the alpha with a rgb color' do
          Color.new(255,127,64, :type => :rgb, :alpha => 0.1).alpha.should == 0.1
        end
        
        it 'sets the alpha with a hsl color' do
          Color.new(20, 50.percent, 50.percent, :type => :hsl, :alpha => 0.75).alpha.should == 0.75
        end
      end
    end
    
    describe 'background' do
      describe 'autodetection' do
        describe 'different detection types' do
          it 'ignores the background with a transparent color' do
            Color.new(:transparent, :background => :black).background.should == nil
          end
      
          it 'sets the background with a keyword type' do
            Color.new(:lightyellow, :background => :black).background.should == Color.new(:black)
          end
      
          it 'sets the background with a hex color' do
            Color.new('#666', :background => :black).background.should == Color.new(:black)
          end
      
          it 'sets the background with a rgb color' do
            Color.new(100.percent, 50.percent, 25.percent, :background => :black).background.should == Color.new(:black)
          end
      
          it 'sets the background with a hsl color' do
            Color.new(20.degrees, 50.percent, 50.percent, :background => :black).background.should == Color.new(:black)
          end
      
          it 'sets the background to :white by default' do
            Color.new(:lightyellow).background.should == Color.new(:white)
          end
        end
        
        describe "different background types/arguments" do
          it 'takes background a keyword arguments' do
            Color.new(:lightyellow, :background => :black).background.should == Color.new(:black)
          end
      
          it 'takes background with hex color arguments' do
            Color.new(:lightyellow, :background => '#000').background.should == Color.new(:black)
          end
      
          it 'takes background with rgb color arguments' do
            Color.new(:lightyellow, :background => [0,0,0]).background.should == Color.new(:black)
          end
      
          it 'takes background with hsl color arguments' do
            Color.new(:lightyellow, :background => [0.degrees, 0, 0]).background.should == Color.new(:black)
          end
        end
      end
      
      describe 'explicit typing' do
        it 'ignores the background with a transparent color' do
          Color.new(:transparent, :background => :black, :type => :transparent).background.should == nil
        end
    
        it 'sets the background with a keyword type' do
          Color.new(:lightyellow, :background => :black, :type => :keyword).background.should == Color.new(:black)
        end
    
        it 'sets the background with a hex color' do
          Color.new('#666', :background => :black, :type => :hex).background.should == Color.new(:black)
        end
    
        it 'sets the background with a rgb color' do
          Color.new(100.percent, 50.percent, 25.percent, :background => :black, :type => :rgb).background.should == Color.new(:black)
        end
    
        it 'sets the background with a hsl color' do
          Color.new(20.degrees, 50.percent, 50.percent, :background => :black, :type => :hsl).background.should == Color.new(:black)
        end
      end
    end
  end
  
  describe 'alpha' do
    describe 'acceptable values' do
      before do
        @color = Color.new('666')
      end
      
      it 'takes ratios' do
        @color.alpha = 0.5
        @color.alpha.should == 0.5
      end
      
      it 'should raise an error if the ratio is out of range' do
        lambda { @color.alpha = 1.1 }.should raise_error( Color::RatioError )
      end
      
      it 'takes percentages' do
        @color.alpha = 72.5.percent
        @color.alpha.should == 0.725
      end
      
      it 'accepts integers as percentages' do
        @color.alpha = 78
        @color.alpha.should == 0.78
      end
      
      it 'should raise an error if the percentage is out of range' do
        lambda { @color.alpha = 300.percent }.should raise_error(Color::PercentageError)
      end
    end
  end
  
  describe 'background' do
    before do
      @background = Color.new(:lightyellow)
      @color = Color.new(:black, :alpha => 0.5)
    end
    
    it 'takes a color object' do
      @color.background = @background
      @color.background.should == @background
    end
    
    it 'otherwise tries to construct a color object from the arguments' do
      @color.background = :lightyellow
      @color.background.should == @background
    end
  end
  
  describe 'comparisons' do
    it 'should be === if the colors have the same object id' do
      (Color.new(:lightyellow) === Color.new(:lightyellow)).should == false
      color = Color.new(:lightyellow)
      (color === color).should == true
    end
    
    it 'should be =~ if the colors have the same rgb, but different alphas' do
      (Color.new(:lightyellow, :alpha => 0.5) =~ Color.new(:lightyellow)).should == true
    end
    
    describe '==' do
      it 'should be false if the alpha is different' do
        Color.new(255, 255, 224, :alpha => 0.5).should_not == Color.new(:lightyellow)
      end
      
      it 'should be false if the rgb values are different' do
        Color.new(255, 255, 225, :alpha => 1.0).should_not == Color.new(:lightyellow)
      end
      
      it 'should be == if the colors have the same rgb and alpha' do
        Color.new(255, 255, 224, :alpha => 1.0).should == Color.new(:lightyellow)
      end
    
      it 'should be indifferent to backgrounds' do
        Color.new(255, 255, 224, :alpha => 1.0, :background => :black).should == Color.new(:lightyellow)
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
        Color.normalize_degrees(30).should == 30/360.0
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

  describe 'type transformation' do
    before do
      @red_values = {
        :rgb => [100, 25, 25],
        :hex => ['641919', 0x641919],
        :hsl => [0.degrees, 0.6, 0.25]
      }
      @green_values = {
        :rgb => [25, 100, 25],
        :hex => ['196419', 0x196419],
        :hsl => [120.degrees, 0.60, 0.25]
      }
      @blue_values = {
        :rgb => [25, 25, 100],
        :hex => ['191964', 0x191964],
        :hsl => [240.degrees, 0.60, 0.25]
      }
    end
    
    describe '#set_hsl' do
      before do
        @red = Color.new(*@red_values[:rgb])
        @red.set_hsl
        @blue = Color.new(*@blue_values[:rgb])
        @blue.set_hsl
        @green = Color.new(*@green_values[:rgb])
        @green.set_hsl
      end
    
      it 'changes the type to :hsl' do
        @red.type.should == :hsl
        @blue.type.should == :hsl
        @green.type.should == :hsl
      end
    
      it 'converts adds hsl value' do
        @red.h.should be_within(TOLERANCE).of(Color.normalize_degrees(@red_values[:hsl][0]))
        @red.s.should be_within(TOLERANCE).of( @red_values[:hsl][1])
        @red.l.should be_within(TOLERANCE).of(@red_values[:hsl][2])
      
        @green.h.should be_within(TOLERANCE).of(Color.normalize_degrees(@green_values[:hsl][0]))
        @green.s.should be_within(TOLERANCE).of( @green_values[:hsl][1])
        @green.l.should be_within(TOLERANCE).of(@green_values[:hsl][2])
      
        @blue.h.should be_within(TOLERANCE).of(Color.normalize_degrees(@blue_values[:hsl][0]))
        @blue.s.should be_within(TOLERANCE).of( @blue_values[:hsl][1])
        @blue.l.should be_within(TOLERANCE).of(@blue_values[:hsl][2])
      end
    end
    
    describe '#set_rgb' do
      before do
        @color = Color.new('#555')
        @color.set_rgb
      end
      
      it 'changes the type' do
        @color.type.should == :rgb
      end
    end
    
    describe '#set_hex' do
      before do
        @red = Color.new(*@red_values[:rgb])
      end
      
      it 'sets the hex and hex_6' do
        @red.hex = 'foo'
        @red.hex_6 = 'foo'
        @red.set_hex
        @red.hex.should == @red_values[:hex][0]
        @red.hex_6.should == @red_values[:hex][1]
      end
      
      it 'sets the type to :hex' do
        @red.set_hex
        @red.type.should == :hex
      end
    end
    
    describe '#hsl_to_rgb' do
      before do
        @red = Color.new(*@red_values[:hsl])
        @red.set_hex
        @red.l += 0.1
        @red.hsl_to_rgb
      end
      
      it 'resets the r, g, b values from h, s, l' do
        @red.r.should be_within(TOLERANCE).of(143/255.0)
        @red.g.should be_within(TOLERANCE).of(36/255.0)
        @red.b.should be_within(TOLERANCE).of(36/255.0)
      end
      
      it 'clears the hex' do
        @red.hex.should == nil
        @red.hex_6.should == nil
      end
    end
  end

  describe 'modification' do
    before do
      @red_values = {
        :rgb => [100, 25, 25],
        :hex => ['641919', 0x641919],
        :hsl => [Color.normalize_degrees(0.degrees), 0.6, 0.25]
      }
      @red = Color.new(*@red_values[:rgb])
    end
    
    describe 'shift' do
      describe 'lighten!' do
        before do
          @red.lighten!
        end
        
        it 'adds 10% to the l value by default' do
          @red.l.should be_within(TOLERANCE).of(@red_values[:hsl][2] + 0.1)
        end
        
        it 'recalculates the rgb' do
          @red.r.should be_within(TOLERANCE).of(143/255.0)
          @red.g.should be_within(TOLERANCE).of(36/255.0)
          @red.b.should be_within(TOLERANCE).of(36/255.0)
        end
        
        it 'takes a percentage argument and adds that from the l' do
          l = @red.l
          @red.lighten!(30.percent)
          @red.l.should == l + 0.30
        end
        
        it 'takes a ratio argument' do
          l = @red.l
          @red.lighten!(0.21)
          @red.l.should == l + 0.21
        end
        
        it 'assumes integers are percentages' do
          l = @red.l
          @red.lighten!(20)
          @red.l.should == l + 0.2
          @red.lighten!(80)
          @red.l.should == 1.0
        end
        
        it 'should cap at 100 percent' do
          @red.lighten!(0.80)
          @red.l.should == 1.0
        end
      end
      
      describe 'lighten' do
        before do
          @less_red = @red.lighten
        end
        
        it 'should not affect the originating color' do
          @red.type.should == :rgb
          @red.r.should be_within(TOLERANCE).of(0.4)
        end
        
        it 'should return a transformed object' do
          @less_red.r.should be_within(TOLERANCE).of(143/255.0)
          @less_red.g.should be_within(TOLERANCE).of(36/255.0)
          @less_red.b.should be_within(TOLERANCE).of(36/255.0)
        end
      end
      
      describe 'darken!' do
        before do
          @red.darken!
        end
        
        it 'makes subtracts 10% to the l value by default' do
          @red.l.should be_within(TOLERANCE).of(@red_values[:hsl][2] - 0.1)
        end
        
        it 'recalculates the rgb' do
          @red.r.should be_within(TOLERANCE).of(61/255.0)
          @red.g.should be_within(TOLERANCE).of(15/255.0)
          @red.b.should be_within(TOLERANCE).of(15/255.0)
        end
        
        it 'takes a percentage argument and subtracts that from the l' do
          l = @red.l
          @red.darken!(5.percent)
          @red.l.should == l - 0.05
        end
        
        it 'takes a ratio argument' do
          l = @red.l
          @red.darken!(0.07)
          @red.l.should == l - 0.07
        end
      end
    
      describe 'darken' do
        before do
          @darker_red = @red.darken
        end
        
        it 'should not affect the originating color' do
          @red.type.should == :rgb
          @red.r.should be_within(TOLERANCE).of(0.4)
        end
        
        it 'should return a transformed object' do
          @darker_red.r.should be_within(TOLERANCE).of(61/255.0)
          @darker_red.g.should be_within(TOLERANCE).of(15/255.0)
          @darker_red.b.should be_within(TOLERANCE).of(15/255.0)
        end
      end
    
      describe 'saturate!' do
        before do
          @red.saturate!
        end
        
        it 'adds 10% to the s value by default' do
          @red.s.should be_within(TOLERANCE).of(@red_values[:hsl][1] + 0.1)
        end
        
        it 'recalculates the rgb' do
          @red.r.should be_within(TOLERANCE).of(108/255.0)
          @red.g.should be_within(TOLERANCE).of(19/255.0)
          @red.b.should be_within(TOLERANCE).of(19/255.0)
        end
        
        it 'takes a percentage argument and adds that from the s' do
          s = @red.s
          @red.saturate!(30.percent)
          @red.s.should == s + 0.30
        end
        
        it 'takes a ratio argument' do
          s = @red.s
          @red.saturate!(0.21)
          @red.s.should be_within(TOLERANCE).of(s + 0.21)
        end
        
        it 'assumes integers are percentages' do
          s = @red.s
          @red.saturate!(20)
          @red.s.should == s + 0.2
          @red.saturate!(80)
          @red.s.should == 1.0
        end
        
        it 'should cap at 100 percent' do
          @red.saturate!(0.80)
          @red.s.should == 1.0
        end
        
        it 'aliases to #brighten' do
          @red.brighten!(0.8)
          @red.s.should == 1.0
        end
      end
      
      describe 'saturate' do
        before do
          @brighter_red = @red.saturate
        end
        
        it 'should not affect the originating color' do
          @red.type.should == :rgb
          @red.r.should be_within(TOLERANCE).of(0.4)
        end
        
        it 'should return a transformed object' do
          @brighter_red.r.should be_within(TOLERANCE).of(108/255.0)
          @brighter_red.g.should be_within(TOLERANCE).of(19/255.0)
          @brighter_red.b.should be_within(TOLERANCE).of(19/255.0)
        end
      end
      
      describe 'dull!' do
        before do
          @red.dull!
        end
        
        it 'adds 10% to the s value by default' do
          @red.s.should be_within(TOLERANCE).of(@red_values[:hsl][1] - 0.1)
        end
        
        it 'recalculates the rgb' do
          @red.r.should be_within(TOLERANCE).of(96/255.0)
          @red.g.should be_within(TOLERANCE).of(32/255.0)
          @red.b.should be_within(TOLERANCE).of(32/255.0)
        end
        
        it 'takes a percentage argument and adds that from the s' do
          s = @red.s
          @red.dull!(30.percent)
          @red.s.should be_within(TOLERANCE).of(s - 0.30)
        end
        
        it 'takes a ratio argument' do
          s = @red.s
          @red.dull!(0.21)
          @red.s.should be_within(TOLERANCE).of(s - 0.21)
        end
        
        it 'assumes integers are percentages' do
          s = @red.s
          @red.dull!(20)
          @red.s.should be_within(TOLERANCE).of(s - 0.2)
          @red.dull!(80)
          @red.s.should == 0.0
        end
        
        it 'should cap at 100 percent' do
          @red.dull!(0.80)
          @red.s.should == 0.0
        end
        
        it 'aliases to #desaturate' do
          @red.desaturate!(0.8)
          @red.s.should == 0.0
        end
      end
      
      describe 'dull' do
        before do
          @dull_red = @red.dull
        end
        
        it 'should not affect the originating color' do
          @red.type.should == :rgb
          @red.r.should be_within(TOLERANCE).of(0.4)
        end
        
        it 'should return a transformed object' do
          @dull_red.r.should be_within(TOLERANCE).of(96/255.0)
          @dull_red.g.should be_within(TOLERANCE).of(32/255.0)
          @dull_red.b.should be_within(TOLERANCE).of(32/255.0)
        end
      end
    end
    
    describe 'rotate' do
      describe 'arbitrary' do
        it 'defaults to 10 degrees' do
          @new = @red.rotate
          @new.h.should be_within(TOLERANCE).of(10/360.0)
        end
        
        it 'takes other positive degree values' do
          @new = @red.rotate(30.degrees)
          @new.h.should be_within(TOLERANCE).of(30/360.0 )
        end
        
        it 'takes negative degrees' do
          @new = @red.rotate(-20.degrees)
          @new.h.should be_within(TOLERANCE).of((360-20)/360.0 )
        end
        
        it 'will rotate beyond end points' do
          @new = @red.rotate(300.degrees)
          @new.h.should be_within(TOLERANCE).of(300/360.0)
          
          @new.rotate!(100.degrees)
          @new.h.should be_within(TOLERANCE).of(40/360.0)
        end
        
        it 'takes ratios' do
          @red.rotate(0.5).h.should be_within(TOLERANCE).of(0.5)
        end
        
        it 'calculates the rgb values' do
          @new = @red.rotate(0.5)
          @new.r.should be_within(TOLERANCE).of(26/255.0)
          @new.g.should be_within(TOLERANCE).of(102/255.0)
          @new.b.should be_within(TOLERANCE).of(102/255.0)
        end
        
        it 'returns a new color object' do
          @new = @red.rotate(0.5)
          @new.should_not == @red
        end
        
        it 'does not modify the existing object' do
          @red.rotate(0.5)
          @red.type.should == :rgb
          @red.r.should be_within(TOLERANCE).of(@red_values[:rgb][0]/255.0)
        end
        
        it 'has a ! method that modifies self' do
          @red.rotate!(0.5)
          @red.type.should == :hsl
          @red.r.should be_within(TOLERANCE).of(26/255.0)
        end
      end
      
      describe 'compliment' do
        it 'rotates half way around' do
          @red.compliment.should == @red.rotate(0.5)
        end
      end
      
      describe '#dial' do
        it 'gives triangular colors' do
          @red.triangulate.should == [@red, @red.rotate(120.degrees), @red.rotate(240.degrees)]
        end
        
        it 'gives offset triangular colors' do
          dial = @red.triangulate(1/6.0)
          dial[0].should == @red.rotate(1/6.0)
          dial[1].should == @red.rotate(0.5)
          dial[2].should == @red.rotate(5/6.0)
        end
        
        it 'dialing allows dividing by any integer' do
          @red.dial(5).should == [
            @red,
            @red.rotate((360/5.0).degrees),
            @red.rotate((2*360/5.0).degrees),
            @red.rotate((3*360/5.0).degrees),
            @red.rotate((4*360/5.0).degrees)
          ]
        end
        
        it 'dailing allows offset too' do
          @red.dial(5, 120.degrees).should == [
            @red.rotate(120.degrees),
            @red.rotate((120 + 360/5.0).degrees),
            @red.rotate((120 + 2*360/5.0).degrees),
            @red.rotate((120 + 3*360/5.0).degrees),
            @red.rotate((120 + 4*360/5.0).degrees)
          ]
        end
      end
      
      describe 'warmer' do
        it 'does nothing if at the warmest hue' do
          @red.rotate!(Color::WARMEST_HUE)
          @red.warmer.should == @red
        end
        
        it 'does nothing if at the coldest hue' do
          @red.rotate!(Color::COLDEST_HUE)
          @red.warmer.should == @red
        end
        
        describe 'direction' do
          before do
            @red.rotate!(0.5)
          end
          
          describe 'hue is between 0 degrees and 240 degrees' do
            it 'defaults to rotating 10 degrees lower' do
              @red.warmer.h.should be_within(TOLERANCE).of( 0.5 - 10/360.0 )
            end
            
            it 'will not go below the warmest point' do
              # currently at 180
              @red.rotate!(-175.degrees) # to 5 degrees
              @red.warmer.h.should be_within(TOLERANCE).of(0.0) # subtract 10 degrees, should stop at 0
            end
            
            it 'takes an custom rotation amount' do
              @red.warmer(0.4).h.should be_within(TOLERANCE).of(0.5 - 0.4)
            end
          end
          
          describe "hue is between 240 degrees and 360" do
            before do
              @red.rotate! 0.25 # 270 degrees 
            end
            
            it 'defaults to rotating 10 degrees higher' do
              @red.warmer.h.should be_within( TOLERANCE ).of( 0.75 + 10/360.0 )
            end
            
            it 'takes a custom rotation amount' do
              @red.warmer(0.2).h.should be_within( TOLERANCE ).of( 0.95 )
            end
            
            it 'will not go higher than 360' do
              @red.warmer(0.3).h.should be_within( TOLERANCE ).of( 0.0 )
            end
          end
        end
      end
      
      describe 'cooler' do
        it 'does nothing if at the warmest hue'
        it 'does nothing if at the coldest hue'
        it 'defaults to rotating 10 degrees'
        it 'takes an arbitrary amount'
        it 'will not rotate past the warmest spot'
      end
    end
    
    describe 'mixing' do
      describe 'layering' do
      end
      
      describe 'averaging' do
      end
      
      describe 'mixing on another ratio' do
      end
      
      describe 'multiplication' do
      end
      
      describe 'division' do
      end
    end
  end
  
  describe 'rendering' do
    it 'renders as hex unless there it has some transparency'
    it 'renders as rgba if there is transparency'
    it 'renders flattened to hex when there is a background'
    it 'renders to hsl (a)'
    
    describe 'keyword' do
      it 'renders to keyword'
      it 'renders to hex if a keyword cannot be found and there is not transparency'
      it 'renders to rgba if a keyword cannot be found and there is transparency'
    end
  end
end