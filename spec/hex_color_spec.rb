require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

HexColor = StyleTrain::HexColor unless defined?( HexColor )

describe HexColor do
  it 'should expand a 3-digit hex' do 
    HexColor.expand('333').should == '333333'
  end
  
  it 'should convert hex to rgb' do
    # 0 1 2 3  4 5 6 7  8 9 A B  C D E F 
    HexColor.to_rgb('333').should == [64, 64, 64]
  end      
end  
