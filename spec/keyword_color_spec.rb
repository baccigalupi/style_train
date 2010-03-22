require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

KeywordColor = StyleTrain::KeywordColor unless defined?( KeywordColor )

describe KeywordColor do
  describe 'accessors' do
    it 'should have methods for #keyword= and #keyword' do
      KeywordColor.instance_methods.should include( 'keyword=', 'keyword' )
    end 
  
    it 'should raise an error if the keyword is not found' do 
      lambda{ KeywordColor.new(:color => :puke) }.should raise_error( KeywordColor::KeywordError)
      color = KeywordColor.new(:color => :lightyellow)
      lambda{ color.keyword = :puke }.should raise_error(KeywordColor::KeywordError)
    end
    
    it 'should set the keyword attribute' do 
      color = KeywordColor.new(:color => :lightyellow) 
      color.keyword.should == :lightyellow
    end   
  end 
  
  describe 'initialization' do
    describe 'from a color' do  
      it 'should find a keyword if it maps' do
        rgb = RGBcolor.new(:color => [255,255,224]) 
        light_yellow = KeywordColor.new( rgb )
        light_yellow.r.should == 255
        light_yellow.g.should == 255
        light_yellow.b.should == 224 
      end 
      
      it 'should raise an error if it does not map' do
        rgb = RGBcolor.new(:color => [255,255,220]) 
        lambda{ KeywordColor.new( rgb ) }.should raise_error( KeywordColor::KeywordError )
      end   
    end
    
    describe 'from a keyword' do
      it 'should have the right rgb values' do 
        light_yellow = KeywordColor.new(:color => :lightyellow)
        light_yellow.r.should == 255
        light_yellow.g.should == 255
        light_yellow.b.should == 224
      end
    end
  end 
  
  describe '#to_s' do
  end  
  
end  
