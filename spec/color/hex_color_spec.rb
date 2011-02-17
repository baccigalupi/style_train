require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

HexColor = StyleTrain::HexColor unless defined?( HexColor )

describe HexColor do
  describe 'class methods' do
    it 'should expand a 3-digit hex' do 
      HexColor.expand('333').should == 0x333333
    end   
  end
  
  describe 'initialization' do
    describe 'from another color' do
      it 'should convert correctly from a RGB color' do
        color = StyleTrain::RGBcolor.new(:color => [20, 40, 60])
        hex = HexColor.new(color)
        hex.r.should == color.r
        hex.g.should == color.g
        hex.b.should == color.b 
        hex.hex.upcase.should == '14283C'
        hex.hex_6.should == 0x14283C    
      end  
    end 
    
    describe 'from a hex without a hash and possibly a number' do 
      before do  
        @gray = HexColor.new(:color => 666)
        @red = HexColor.new(:color => '993300') 
        @gold = HexColor.new(:color => 'FC0') 
      end
         
      it 'should set the #hex attribute' do 
        @gray.hex.should == '666'
        @red.hex.should == '993300'
        @gold.hex.should == 'FC0'
      end
      
      it 'should set the #hex_6 attribute' do 
        @gray.hex_6.should == 0x666666
        @red.hex_6.should == 0x993300 
        @gold.hex_6.should == 0xFFCC00
      end
      
      it 'should set the #r attribute' do
        @gray.r.should == 102
        @red.r.should == 153
        @gold.r.should == 255 
      end
      
      it 'should set the #g attribute' do
        @gray.g.should == 102
        @red.g.should == 51 
        @gold.g.should == 204   
      end
      
      it 'should set the #b attribute' do
        @gray.b.should == 102
        @red.b.should == 0   
        @gold.b.should == 0
      end   
    end
    
    describe 'from a three digit hex' do 
      before do  
        @gray = HexColor.new(:color =>'#666')
        @red = HexColor.new(:color => '#930') 
        @gold = HexColor.new(:color => '#FC0') 
      end
         
      it 'should set the #hex attribute' do 
        @gray.hex.should == '666'
        @red.hex.should == '930'
        @gold.hex.should == 'FC0'
      end
      
      it 'should set the #hex_6 attribute' do 
        @gray.hex_6.should == 0x666666
        @red.hex_6.should ==  0x993300 
        @gold.hex_6.should == 0xFFCC00
      end
      
      it 'should set the #r attribute' do
        @gray.r.should == 102
        @red.r.should == 153
        @gold.r.should == 255 
      end
      
      it 'should set the #g attribute' do
        @gray.g.should == 102
        @red.g.should == 51 
        @gold.g.should == 204   
      end
      
      it 'should set the #b attribute' do
        @gray.b.should == 102
        @red.b.should == 0   
        @gold.b.should == 0
      end      
    end
    
    describe 'from a 6 digit hex' do
      before do  
        @gray = HexColor.new(:color => '#666666')
        @red = HexColor.new(:color =>'#993300') 
        @gold = HexColor.new(:color => '#FFCC00') 
        @mix = HexColor.new(:color => '#6b602f')
      end
         
      it 'should set the #hex attribute' do 
        @gray.hex.should == '666666'
        @red.hex.should == '993300'
        @gold.hex.should == 'FFCC00'
        @mix.hex.should == '6b602f'   
      end
      
      it 'should set the #hex_6 attribute' do 
        @gray.hex_6.should == 0x666666
        @red.hex_6.should == 0x993300 
        @gold.hex_6.should == 0xFFCC00
        @mix.hex_6.should == 0x6b602f
      end
      
      it 'should set the #r attribute' do
        @gray.r.should == 102
        @red.r.should == 153
        @gold.r.should == 255 
        @mix.r.should == 107
      end
      
      it 'should set the #g attribute' do
        @gray.g.should == 102
        @red.g.should == 51 
        @gold.g.should == 204   
        @mix.g.should == 96
      end
      
      it 'should set the #b attribute' do
        @gray.b.should == 102
        @red.b.should == 0   
        @gold.b.should == 0
        @mix.b.should == 47
      end
    end
  end  

  describe '#to_s' do 
    before do 
      @color = HexColor.new(:color => '666')
    end
    
    it 'should render with the original passed in value if no alpha is present' do
      @color.to_s.should == "#666"
    end
    
    it 'should render as rgba if alpha is present' do
      @color.alpha = 0.5
      @color.to_s.should == "rgba( 102, 102, 102, 0.5 )"
    end
  end
end  
