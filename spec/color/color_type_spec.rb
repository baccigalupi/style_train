require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

ColorType = StyleTrain::ColorType unless defined?( ColorType ) 
HexColor = StyleTrain::HexColor unless defined?( HexColor )
KeywordColor = StyleTrain::KeywordColor unless defined?( KeywordColor )
RGBcolor = StyleTrain::RGBcolor unless defined?( RGBcolor )

describe ColorType do 
  describe 'class methods' do
    describe 'degrees' do
      it 'should return a number between 0 and 359 when given such a number' do
        ColorType.normalize_degrees(42).should == 42
      end
      
      it 'should return a number when given a string' do
        ColorType.normalize_degrees('42').should == 42
      end
      
      it 'should normalize a number greater than 359' do
        ColorType.normalize_degrees(360).should == 0
        ColorType.normalize_degrees(460).should == 100
      end
      
      it 'should normalize negative number' do
        ColorType.normalize_degrees(-127).should == 233
      end
    end
    
    describe 'percentages' do
      it 'should return false if string does not contain a percentage' do 
        ColorType.percentage( '255' ).should == false
      end  
    
      it 'should return the number' do
        ColorType.percentage( '33%' ).should == 33
      end
    
      it 'should return decimal values of percentages' do
        ColorType.percentage( '33.5%' ).should == 33.5
      end 
    
      it 'should raise an argument error if the percentage is out of range' do 
        lambda { ColorType.percentage( '133%' ) }.should raise_error( ArgumentError )
      end  
    end
  
    describe 'byte numbers' do
      it 'should return the number' do
        ColorType.byte( '33' ).should == 33
        ColorType.byte( '0' ).should == 0
      end
    
      it 'should raise an argument error if the number is out of range' do 
        lambda { ColorType.byte( '256' ) }.should raise_error( ArgumentError )
      end  
    end
  
    describe 'conversion' do
      it 'should convert from byte numbers to percentages' do 
        ColorType.byte_to_percentage( 255 ).should == 100
        ColorType.byte_to_percentage( 127 ).should == 50
        ColorType.byte_to_percentage( 64 ).should == 25
        ColorType.byte_to_percentage( 0 ).should == 0
        lambda{ ColorType.byte_to_percentage(256) }.should raise_error( ColorType::ByteNumberError )
        lambda{ ColorType.byte_to_percentage(-5) }.should raise_error( ColorType::ByteNumberError )
        lambda{ ColorType.byte_to_percentage(122.6) }.should_not raise_error
      end
  
      it 'should convert from percentage to byte' do 
        ColorType.percent_to_byte( 100 ).should == 255
        ColorType.percent_to_byte( 50 ).should == 127
        ColorType.percent_to_byte( 25 ).should == 64
        ColorType.percent_to_byte( 0 ).should == 0
        lambda{ ColorType.percent_to_byte(101) }.should raise_error( ColorType::PercentageError )
        lambda{ ColorType.percent_to_byte(-5) }.should raise_error( ColorType::PercentageError )
        lambda{ ColorType.percent_to_byte(22.6) }.should_not raise_error 
      end 
      
      it 'custom argument errors should raise custom messages' do
        begin
          ColorType.percent_to_byte(101)
        rescue Exception => e
          e.message.match(/must be between 0 and/)
        end
    
        begin
          ColorType.byte_to_percentage(256)
        rescue Exception => e
          e.message.match(/must be between 0 and/)
        end    
      end         
    end
  
    describe '#is_color?' do
      it 'should recognize any of the color types' do
        ColorType.is_color?(KeywordColor.new(:color => :linen)).should be_true
        ColorType.is_color?(RGBcolor.new(:color => [0,0,0])).should be_true
      end
      
      it 'should be false if not a color type' do
        ColorType.is_color?( nil ).should be_false
        ColorType.is_color?( {} ).should be_false
        ColorType.is_color?( [] ).should be_false
      end
    end
  
    describe '#make' do
      it 'returns nil if not the right type' do
        HexColor.make(:color => :lightyellow).should be_nil
      end
      
      it 'returns an instance on the color type if arguments are correct' do
        KeywordColor.make(:color => :lightyellow).is_a?(KeywordColor).should be_true
      end
    end
  end
  
  describe 'instance methods' do
    describe 'conversion' do
      describe 'from rgb' do
        before do
          @color = RGBcolor.new(:color => [0,0,0])
        end 
        
        it 'to keyword works' do
          new_color = @color.to(:keyword)
          new_color.class.should == KeywordColor 
          new_color.keyword.should == :black
        end  
        
        it 'to hex works' do
          new_color = @color.to(:hex)
          new_color.class.should == HexColor 
          new_color.hex_6.should == 0x000000
        end
      end
      
      describe 'from hex' do
        before do
          @color = HexColor.new(:color => '#000')
        end
        
        it 'to keyword works' do
          new_color = @color.to(:keyword) 
          new_color.class.should == KeywordColor 
          new_color.keyword.should == :black
        end
        
        it 'to rgb works' do 
          new_color = @color.to(:rgb)
          new_color.class.should == RGBcolor 
          new_color.red.should == 0
          new_color.green.should == 0
          new_color.blue.should == 0
        end
      end  
      
      describe 'from keyword' do
        before do
          @color = KeywordColor.new(:color => :black)
        end
        
        it 'to rgb works' do 
          new_color = @color.to(:rgb)
          new_color.class.should == RGBcolor 
          new_color.red.should == 0
          new_color.green.should == 0
          new_color.blue.should == 0
        end 
        
        it 'to hex works' do
          new_color = @color.to(:hex)
          new_color.class.should == HexColor 
          new_color.hex_6.should == 0x000000
        end  
      end
    end
  
    describe 'alpha' do 
      before do 
        @color = KeywordColor.new(:color => :black)
      end
      
      it 'should be 1.0 by default' do
        @color.alpha.should == 1.0
      end
      
      it 'should be 1.0 if alpha is entered as 1' do
        @color.alpha = 1
        @color.alpha.should == 1.0
      end
      
      it 'should be be 0.0 if set to 0' do
        @color.alpha = 0
        @color.alpha.should == 0.0
      end
      
      it 'should be a decimal value between zero and one if set that way' do
        @color.alpha = 0.5
        @color.alpha.should == 0.5
      end
      
      it 'should be set via the initializer' do
        color = KeywordColor.new(:color => :black, :alpha => 0.5) 
        color.alpha.should == 0.5
      end 
      
      it 'should raise an error if out of range' do
        lambda{ @color.alpha = 1.5 }.should raise_error
      end 
      
      describe '#alpha?' do
        it '#should be false if alpha value is 1.0' do
          @color.alpha?.should == false
        end  
      
        it 'should be true if alpha is greater than 0 and less than 1' do
          @color.alpha = 0.5
          @color.alpha?.should be_true
        end 
      end  
    end                  
    
    describe 'comparisons' do
      before do
        @hex = HexColor.new(:color => '#000')
        @keyword = KeywordColor.new(:color => :black)
      end
       
      describe '=~' do
        it 'should be true if the r, g, b values are the same' do
          (@hex =~ @keyword).should == true
        end
        
        it 'should be true even if the alpha values are different' do
          @hex.alpha = 0.5
          (@hex =~ @keyword).should == true
        end
        
        it 'should compare with the delagate of a color' do
          (@hex =~ StyleTrain::Color.new('#000')).should == true
          (@hex =~ StyleTrain::Color.new('#fff')).should == false
        end 
      end
      
      describe '==' do
        it 'should be true if the colors are =~ and also have the same alpha' do
          (@hex == @keyword).should == true
        end
        
        it 'should be false if the alphas are different' do 
          @hex.alpha = 0.5
          (@hex == @keyword).should == false
        end
        
        it 'should be false if the r, g, b values are different' do
          color = KeywordColor.new(:color => :maroon)
          (color == @keyword).should == false
        end
      end
      
      describe '===' do
        before do
          @key2 = KeywordColor.new(:color => :black)
        end
          
        it 'should be true if the colors are == and also have the same class' do
          (@key2 === @keyword).should == true
        end 
        
        it 'should be false if the classes are different' do
          (@keyword === @hex).should == false
        end
        
        it 'should be false if the alphas are different' do 
          @key2.alpha = 0.5
          (@key2 == @keyword).should == false
        end
        
        it 'should be false if the r, g, b values are different' do
          color = KeywordColor.new(:color => :maroon)
          (color == @keyword).should == false
        end 
      end    
    end
    
    describe 'mixing' do
      before do
        @rgb = RGBcolor.new(:color => [20,40,60], :alpha => 0.5)
        @hex = HexColor.new(:color => '#666')
        @keyword = KeywordColor.new(:color => :lightyellow) 
      end
      
      describe 'averaging (getting a midway point)' do
        it 'should average the r, g, and b values' do
          color = @rgb.mix(@hex)
          color.r.should == ((102+20)/2.0).round
          color.g.should == ((102+40)/2.0).round
          color.b.should == ((102+60)/2.0).round
        end 
        
        it 'should average the alpha' do
          color = @rgb.mix(@hex)
          color.alpha.should == 0.75
        end
        
        it 'should return the original color type' do 
          color = @rgb.mix(@hex)
          color.class.should == RGBcolor
          
          color = @hex.mix(@rgb)
          color.class.should == HexColor
        end
      end 
      
      describe 'layering' do
        before do
          @white = HexColor.new(:color => '#FFF')
          @shadow = HexColor.new(:color => '#000', :alpha => 0.5)
        end 
        
        it 'should blend on the class method' do
          ColorType.blend(255, 0, 0.5).should == 128
          ColorType.blend(128, 0, 0.5).should == 64
          ColorType.blend(255, 0, 0.25).should == 64
        end
        
        describe 'r, g, b' do
          describe 'opaque top layer' do
            it 'should have the r, g, b values of the top layer' do
              color = @rgb.layer(@hex)
              color.r.should == 102 
              color.g.should == 102
              color.b.should == 102 
            end
          end  
        
          describe 'opaque bottom layer' do
            before do
              @color = @white.layer(@shadow) 
            end 
          
            it 'should mix the r, g, and b in proportion to the top layer\'s alpha' do
              @color.r.should == 128
              @color.g.should == 128
              @color.b.should == 128 
            
              red = RGBcolor.new(:color => [153,0,0], :alpha => 0.25)
              color = @white.layer(red)
              color.r.should == (153*0.25 + 255*0.75).round
              color.g.should == (0*0.25 + 255*0.75).round
              color.b.should == (0*0.25 + 255*0.75).round
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
            color = @rgb.layer(@shadow)
            (color.alpha >= @rgb.alpha).should be_true
            (color.alpha >= @shadow.alpha).should be_true
          end
          
          it 'should calculate the blending of two alphas properly' do
            color = @rgb.layer(@shadow)
            color.alpha.should == 0.75 # 0.5 for the base color, plus 0.5 of the remaining transparency
          end  
        end 
      end  
      
      describe 'blending a ratio of one color to the other' do
        it 'should mix in the correct percentage r, g, and b values' do
          color = @rgb.mix(@hex, 0.25) # only 25% of the @hex
          color.r.should == (102*0.25 + 20*0.75).round
          color.g.should == (102*0.25 + 40*0.75).round
          color.b.should == (102*0.25 + 60*0.75).round
        end 
        
        it 'should average the alpha' do
          color = @rgb.mix(@hex, 0.25)
          color.alpha.should == 0.5*0.75 + 1*0.25
        end
        
        it 'should return the original color type' do 
          color = @rgb.mix(@hex, 0.25)
          color.class.should == RGBcolor
          
          color = @hex.mix(@rgb, 0.25)
          color.class.should == HexColor
        end
        
        it 'returns hex when the original color type cannot be built' do
          color = @keyword.mix(@rgb, 0.25)
          color.class.should == HexColor
        end
      end
    end

    describe 'rendering' do
      # todo: do color specs first, to work out where the blending of background should happen
    end
  end

end  
