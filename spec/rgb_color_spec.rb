require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

RGBcolor = StyleTrain::RGBcolor unless defined?( RGBcolor )

describe RGBcolor do
  
  it 'should have methods for #red=, #green= and #blue=' do
    RGBcolor.instance_methods.should include( 'red=', 'green=', 'blue=' )
  end 
  
  describe 'array initialization' do
    it '#red #green and #blue should be set to passed values' do 
      color = RGBcolor.new(:color => [20, 40, 60])
      color.red.should == 20
      color.green.should == 40
      color.blue.should == 60
    
      color = RGBcolor.new(:color => ['20', '40', '60'])
      color.red.should == '20'
      color.green.should == '40'
      color.blue.should == '60'
    
      color = RGBcolor.new(:color => ['0%', '50%', '100%'])
      color.red.should == '0%'
      color.green.should == '50%'
      color.blue.should == '100%'
    end
    
    it '#r #g and #b (the internal storage ) should be set' do
      color = RGBcolor.new(:color => [20, 40, 60])
      color.r.should == 20
      color.g.should == 40
      color.b.should == 60 
      
      color = RGBcolor.new(:color => ['20', '40', '60'])
      color.r.should == 20
      color.g.should == 40
      color.b.should == 60 
      
      color = RGBcolor.new(:color => ['0%', '50%', '100%'])
      color.r.should == 0
      color.g.should == 127
      color.b.should == 255 
    end
  end
  
  
  # This should be a shared example
  describe 'alpha' do 
    it 'should be 1.0 by default' do
      color = RGBcolor.new(:color => ['0%', '50%', '100%']) 
      color.alpha.should == 1.0
    end
    
    it 'should be set by the alpha parameter' do 
      color = RGBcolor.new(:color => ['0%', '50%', '100%'], :alpha => 0.5 )
      color.alpha.should == 0.5
      
      color = RGBcolor.new(:color => ['0%', '50%', '100%'], :alpha => '0.5' )
      color.alpha.should == 0.5
    end      
  end  
      
  
end  
