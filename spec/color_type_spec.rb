require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

ColorType = StyleTrain::ColorType unless defined?( ColorType ) 
HexColor = StyleTrain::HexColor unless defined?( HexColor )
KeywordColor = StyleTrain::KeywordColor unless defined?( KeywordColor )
RGBcolor = StyleTrain::RGBcolor unless defined?( RGBcolor )

describe ColorType do 
  describe 'class methods' do
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
  
    describe 'is_color?' do
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

    describe 'rendering' do
      # todo: do color specs first, to work out where the blending of background should happen
    end
  end
end  
