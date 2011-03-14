require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

HSLcolor = StyleTrain::HSLcolor unless defined?( HSLcolor )

describe HSLcolor do
  describe 'attributes' do
    it 'has hue' do
      HSLcolor.instance_methods.should include( 'hue', 'hue=' )
    end
    
    it 'has saturation' do
      HSLcolor.instance_methods.should include( 'saturation', 'saturation=' )
    end
    
    it 'has lightness' do
      HSLcolor.instance_methods.should include( 'saturation', 'saturation=' )
    end
  end
  
  describe 'initialization' do
    it '#hue #saturation and #lightness should be set to passed values' do 
      color = HSLcolor.new(:color => [120, '100%', '50%'])
      color.hue.should == 120
      color.saturation.should == '100%'
      color.lightness.should == '50%'
    end
    
    it 'normalizes the hue' do
      color = HSLcolor.new(:color => [-270, 100.percent, 50.percent])
      color.h.should == 90
    end
    
    it 'raises an error if the percentages are out of scope' do
      lambda { HSLcolor.new( :color => [120, -15.percent, 50.percent])}.should raise_error('foo')
    end

    # it '#r #g and #b (the internal storage ) should be set' do
    #   color = StyRGBcolor.new(:color => [20, 40, 60])
    #   color.r.should == 20
    #   color.g.should == 40
    #   color.b.should == 60 
    # 
    #   color = RGBcolor.new(:color => ['20', '40', '60'])
    #   color.r.should == 20
    #   color.g.should == 40
    #   color.b.should == 60 
    # 
    #   color = RGBcolor.new(:color => ['0%', '50%', '100%'])
    #   color.r.should == 0
    #   color.g.should == 127
    #   color.b.should == 255 
    # end
  end
end