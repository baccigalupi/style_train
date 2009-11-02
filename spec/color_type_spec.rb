require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

ColorType = StyleTrain::ColorType unless defined?( ColorType )

describe ColorType do 
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
  
  describe 'to_X methods' do 
    it 'conversion methods #to_rgb, #to_hsl, #to_keyword, #to_hex should exist' do
      ColorType.instance_methods.should include( 'to_rgb', 'to_hsl', 'to_keyword', 'to_hex' )
    end  
  end 
  
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
