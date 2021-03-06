require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Color = StyleTrain::Color unless defined?(Color)
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
        it 'does nothing if at the warmest hue' do
          @red.rotate!(Color::WARMEST_HUE)
          @red.cooler.should == @red
        end
        
        it 'does nothing if at the coldest hue' do
          @red.rotate!(Color::COLDEST_HUE)
          @red.cooler.should == @red
        end
        
        describe 'direction' do
          before do
            @red.rotate!(0.5)
          end
          
          describe 'hue is between 0 degrees and 240 degrees' do
            it 'defaults to rotating 10 degrees higher' do
              @red.cooler.h.should be_within(TOLERANCE).of( 0.5 + 10/360.0 )
            end
            
            it 'will not go below the coolest point' do
              # currently at 180
              @red.rotate!(60.degrees) # change to 235 degrees
              @red.cooler.h.should be_within(TOLERANCE).of(Color::COLDEST_HUE) # adding 10 degrees should stop at 240
            end
            
            it 'takes an custom rotation amount' do
              @red.cooler(0.1).h.should be_within(TOLERANCE).of(0.5 + 0.1)
            end
          end
          
          describe "hue is between 240 degrees and 360" do
            before do
              @red.rotate! 0.25 # 270 degrees  = 0.75
            end
            
            it 'defaults to rotating 10 degrees lower' do
              @red.cooler.h.should be_within( TOLERANCE ).of( 0.75 - 10/360.0 )
            end
            
            it 'takes a custom rotation amount' do
              @red.cooler(0.05).h.should be_within( TOLERANCE ).of( 0.70 )
            end
            
            it 'will not go lower than than 240 degress' do
              @red.cooler(0.1).h.should be_within( TOLERANCE ).of( Color::COLDEST_HUE )
            end
          end
        end
      end
    end
    
    describe 'combining colors' do
      before :all do
        @black = Color.new('#000')
        @yellow = Color.new(:lightyellow)
        @trans = Color.new(:lightyellow, :alpha => 0.5)
      end
      
      describe 'layering' do
        before do
          @white = Color.new('#FFF')
          @shadow = Color.new('#000', :alpha => 0.5)
          @dark_blue = Color.new(20,40,60, :alpha => 0.5)
        end 
        
        describe 'r, g, b values' do
          describe 'opaque top layer' do
            it 'should have the r, g, b values of the top layer' do
              color = @shadow.layer(@white)
              color.r.should == 1.0 
              color.g.should == 1.0
              color.b.should == 1.0 
            end
          end  
        
          describe 'opaque bottom layer' do
            before do
              @color = @white.layer(@shadow) 
            end 
          
            it 'should mix the r, g, and b in proportion to the top layer\'s alpha' do
              @color.r.should == 0.5
              @color.g.should == 0.5
              @color.b.should == 0.5
              @color.alpha.should == 1.0 
            
              red = Color.new(153,0,0, :alpha => 0.25)
              color = @white.layer(red)
              color.r.should == 0.6*0.25 + 1.0*0.75
              color.g.should == 0*0.25 + 1.0*0.75
              color.b.should == 0*0.25 + 1.0*0.75
            end
          end
        end
        
        describe 'alpha blending' do
          it 'should be 1.0 if bottom layer is opaque' do 
            color = @white.layer(@shadow)
            color.alpha.should == 1.0
          end
          
          it 'should be 1.0 if the top layer is opaque' do
            color = @shadow.layer(@white)
            color.alpha.should == 1.0
          end   
          
          it 'should have an alpha greater than or equal to the composites' do
            color = @dark_blue.layer(@shadow)
            (color.alpha >= @dark_blue.alpha).should be_true
            (color.alpha >= @shadow.alpha).should be_true
          end
          
          it 'should calculate the blending of two alphas properly' do
            color = @dark_blue.layer(@shadow)
            color.alpha.should == 0.75 # 0.5 for the base color, plus 0.5 of the remaining transparency
          end  
        end 
      end
      
      describe 'mix' do
        it 'should not affect either color' do
          black = @black.dup
          yellow = @yellow.dup
          @black.mix(@yellow)
          @black.should == black
          @yellow.should == yellow
        end

        it 'mixes half of each by default' do
          color = @black.mix(@yellow)
          color.r.should == (@yellow.r/2.0)
          color.g.should == (@yellow.g/2.0)
          color.b.should == (@yellow.b/2.0)
          color.alpha.should == 1.0
        end

        it 'mixes alphas' do
          color = @black.mix(@trans)
          color.r.should == (@yellow.r/2.0)
          color.g.should == (@yellow.g/2.0)
          color.b.should == (@yellow.b/2.0)
          color.alpha.should == 0.75
        end
        
        it 'returns a copy, and does not alter the original' do
          color = @black.mix(@trans)
          color.should_not === @black
          color.should_not === @trans
        end

        describe 'on another ratio' do
          it 'will mix on a ratio' do
            color = @black.mix(@trans, 0.25)
            color.r.should == @trans.r*0.25
            color.b.should == @trans.b*0.25
            color.g.should == @trans.g*0.25
            color.alpha.should == 1.0*0.75 + 0.5*0.25
          end
          
          describe '#percent alternate syntax' do
            it 'sets the mix ratio on the color being mixed in' do
              @trans.percent(13)
              @trans.mix_ratio.should == 0.13
            end
            
            it 'will be used by the mix when applied to the first color' do
              color = @black.percent(75).mix(@trans)
              color.r.should == @trans.r*0.25
              color.b.should == @trans.b*0.25
              color.g.should == @trans.g*0.25
              color.alpha.should == 1.0*0.75 + 0.5*0.25
            end
            
            it 'will be used by the mix when applied to the second color' do
              color = @black.mix(@trans.percent(25))
              color.r.should == @trans.r*0.25
              color.b.should == @trans.b*0.25
              color.g.should == @trans.g*0.25
              color.alpha.should == 1.0*0.75 + 0.5*0.25
            end
            
            it 'consumes the mix ratio' do
              color = @black.percent(75).mix(@trans.percent(75))
              @black.mix_ratio.should be_nil
              @trans.mix_ratio.should be_nil
            end
          end
        end
      end
    
      describe 'flatten' do
        it 'does not affect colors with an alpha of 1' do
          @black.background = Color.new(:white)
          color = @black.flatten
          color.should == @black
        end
        
        it 'layers the transparent color onto the background' do
          @yellow.background = @black
          color = @yellow.flatten
          layered = @black.layer(@yellow)
          color.should == layered
        end
        
        it 'ignores the alpha of the background' do
          background = Color.new(:white, :alpha => 0.5)
          @yellow.background = background
          color = @yellow.flatten
          
          background.alpha = 1.0
          color.should == background.layer(@yellow)
        end
      end
    
      describe 'stepping' do
        before :all do
          @black = Color.new('#000')
          @yellow = Color.new(:lightyellow, :alpha => 0.5)
          @steps = @black.step(@yellow)
        end

        it 'returs an array' do
          @steps.is_a?(Array).should be_true
        end

        it 'has 10 steps by default' do
          @steps.size.should == 10
        end

        it 'first color should be the starting point (dupped)' do
          @steps.first.should == @black
          @steps.first.should_not === @black
        end

        it 'last color should be the last point (dupped)' do
          @steps.last.should == @yellow
          @steps.last.should_not === @yellow
        end

        it 'interior steps should be equally spaced colors between the two' do
          mid = @steps[4]
          mid.r.should == @yellow.r/2.0
          mid.g.should == @yellow.g/2.0
          mid.b.should == @yellow.b/2.0
        end

        it 'has takes optional number of steps' do
          @black.step(@yellow, 5).size.should == 5
        end
      end
    end
  end
  
  describe 'rendering' do
    before do
      Color.render_as = nil
    end
    
    it 'inspects' do
      color = Color.new('#000')
      color.inspect.should == "#<#{color.class}:#{color.object_id} @alpha=#{color.alpha} @r=#{color.r} @g=#{color.g} @b=#{color.b}>"
    end
    
    describe 'class level render_as' do
      it 'defaults to :hex' do
        Color.render_as.should == :hex
      end
      
      it 'can be set' do
        Color.render_as = :foo
        Color.render_as.should == :foo
      end
    end
    
    describe '#render' do
      it 'renders to the default render_as method without transparency' do
        color = Color.new(0,0,0)
        color.render.should == '#000000'
      end
    
      it 'renders as rgba if there is transparency' do
        color = Color.new(0.5, 0.5, 0.5, :alpha => 0.5)
        color.render.should == "rgba(50.0%, 50.0%, 50.0%, 0.5)"
      end
      
      describe 'specific render methods' do
        describe ':hex' do
          it 'will render as :hex if alpha is 1' do
            Color.render_as = :rgb
            color = Color.new(0,0,0)
            color.render(:hex).should == '#000000'
          end
          
          it 'will render as :rgba if alpha is less than 1' do
            Color.render_as = :hsl
            color = Color.new(0,0,0, :alpha => 0.9)
            color.render(:hex).should == "rgba(0.0%, 0.0%, 0.0%, 0.9)"
          end
          
          it 'will render as :hex if render_as is set that way' do
            Color.render_as = :hex
            color = Color.new(0,0,0)
            color.render.should == '#000000'
          end
          
          it 'will render as :rgba if render_as is set that way but alpha is less than 1' do
            Color.render_as = :hex
            color = Color.new(0,0,0, :alpha => 0.9)
            color.render.should == "rgba(0.0%, 0.0%, 0.0%, 0.9)"
          end
        end
        
        describe ':hsl' do
          it 'will render as :hsl from #render if the alpha is 1' do
            color = Color.new(0.5, 0.5, 0.5)
            color.set_hsl
            color.render(:hsl).should == "hsl(#{(color.h*360).round}, #{color.s*100}%, #{color.l*100}%)"
          end
          
          it 'will render as hsla from #render if the alpha is less than 1' do
            color = Color.new(0.5, 0.5, 0.5, :alpha => 0.75)
            color.set_hsl
            color.render(:hsl).should == "hsla(#{(color.h*360).round}, #{color.s*100}%, #{color.l*100}%, 0.75)"
          end
          
          it "will render this way when the render_as is set to it and alpha is 1" do
            Color.render_as = :hsl
            color = Color.new(0.5, 0.5, 0.5)
            color.set_hsl
            color.render.should == "hsl(#{(color.h*360).round}, #{color.s*100}%, #{color.l*100}%)"
          end
          
          it 'wil render as hsla with a render_as of :hsl if the alpha is less than 1' do
            Color.render_as = :hsl
            color = Color.new(0.5, 0.5, 0.5, :alpha => 0.75)
            color.set_hsl
            color.render.should == "hsla(#{(color.h*360).round}, #{color.s*100}%, #{color.l*100}%, 0.75)"
          end
        end
        
        describe ':hsla' do
          it 'will render as :hsla if alpha is 1' do
            color = Color.new(0.5, 0.5, 0.5)
            color.set_hsl
            color.render(:hsla).should == "hsla(#{(color.h*360).round}, #{color.s*100}%, #{color.l*100}%, 1.0)"
          end
          
          it 'will render as :hsla if alpha is less than 1' do
            color = Color.new(0.5, 0.5, 0.5, :alpha => 0.2)
            color.set_hsl
            color.render(:hsla).should == "hsla(#{(color.h*360).round}, #{color.s*100}%, #{color.l*100}%, 0.2)"
          end
          
          it 'will render as :hsla when the Colol render_as is set that way' do
            Color.render_as = :hsla
            color = Color.new(0.5, 0.5, 0.5)
            color.set_hsl
            color.render.should == "hsla(#{(color.h*360).round}, #{color.s*100}%, #{color.l*100}%, 1.0)"
          end
        end
        
        describe ':rgb' do
          it 'will render as :rgb from #render if the alpha is 1' do
            color = Color.new(0.5, 0.5, 0.5)
            color.render(:rgb).should == "rgb(#{color.r*100}%, #{color.g*100}%, #{color.b*100}%)"
          end
          
          it 'will render as rgba from #render if the alpha is less than 1' do
            color = Color.new(0.5, 0.5, 0.5, :alpha => 0.75)
            color.render(:rgb).should == "rgba(#{color.r*100}%, #{color.g*100}%, #{color.b*100}%, 0.75)"
          end
          
          it "will render this way when the render_as is set to it and alpha is 1" do
            Color.render_as = :rgb
            color = Color.new(0.5, 0.5, 0.5)
            color.render.should == "rgb(#{color.r*100}%, #{color.g*100}%, #{color.b*100}%)"
          end
          
          it 'wil render as rgba with a render_as of :rgb if the alpha is less than 1' do
            Color.render_as = :rgb
            color = Color.new(0.5, 0.5, 0.5, :alpha => 0.75)
            color.render(:rgb).should == "rgba(#{color.r*100}%, #{color.g*100}%, #{color.b*100}%, 0.75)"
          end
        end
        
        describe ':rgba' do
          it 'will render as :rgba if alpha is 1' do
            color = Color.new(0.5, 0.5, 0.5)
            color.set_rgb
            color.render(:rgba).should == "rgba(#{color.r*100}%, #{color.g*100}%, #{color.b*100}%, 1.0)"
          end
          
          it 'will render as :rgba if alpha is less than 1' do
            color = Color.new(0.5, 0.5, 0.5, :alpha => 0.2)
            color.set_rgb
            color.render(:rgba).should == "rgba(#{color.r*100}%, #{color.g*100}%, #{color.b*100}%, 0.2)"
          end
          
          it 'will render as :rgba when the Colol render_as is set that way' do
            Color.render_as = :rgba
            color = Color.new(0.5, 0.5, 0.5)
            color.set_rgb
            color.render.should == "rgba(#{color.r*100}%, #{color.g*100}%, #{color.b*100}%, 1.0)"
          end
        end
      end
      
      describe 'flattened' do
        it 'will render as the render_as type when opaque' do
          Color.render_as = :hsl
          color = Color.new(:black)
          color.render(:flat).should == Color.new(:black).render_as_hsl
        end
        
        it 'will flatten the color before rendering' do
          Color.render_as = :rgb
          color = Color.new(:black, :alpha => 0.5)
          color.render(:flat).should == Color.new(0.5,0.5,0.5).render_as_rgb
        end
        
        it 'will render as the non-alpha type even with alhpa' do
          Color.render_as = :hex
          color = Color.new(:black, :alpha => 0.5)
          color.render(:flat).should == Color.new(0.5,0.5,0.5).render_as_hex
        end
      end
    
      it 'aliases to #to_s' do
        Color.new(:black).render(:rgba).should == Color.new(:black).to_s(:rgba)
      end
    end
  end
end