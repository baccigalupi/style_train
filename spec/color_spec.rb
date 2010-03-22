require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Color = StyleTrain::Color unless defined?(Color)

describe Color do
  before do
    pending
  end
  
  def act_like_color_type( color_class, args ) 
    color_class.new(:color => args)
  end   
   
  describe 'initialization' do
    describe 'with a keyword' do
      it 'should build an html keyword color' do
        Color.new("gray").to_s.should act_like_color_type(KeywordColor, 'gray').to_s
      end 

      it 'should build a svg keyword color' do 
        Color.new(:linen).to_s.should act_like_color_type(KeywordColor, :linen).to_s
      end
    end   
 
    describe 'with a hex string' do
      it '(3-digit no #) should build a hex color' do 
        Color.new('333').to_s.should act_like_color_type(HexColor, '333').to_s
      end
      
      it '(3-digit with #) should build a hex color' do 
        Color.new('#333').to_s.should act_like_color_type(HexColor, '#333').to_s
      end
      
      it '(6-digit no #) should build a hex color' do  
        Color.new('333333').to_s.should act_like_color_type(HexColor, '333333').to_s
      end
      
      it '(6-digit with #) should build a hex color' do
        Color.new('#333333').to_s.should act_like_color_type(HexColor, '#333333').to_s
      end
    end
 
    describe 'with an rgb array' do
      it '(with a byte array) should build a rgb color' do
        Color.new([127,127,127]).to_s.should act_like_color_type(RGBcolor, [127,127,127]).to_s
      end
      
      it '(with a percentage array) should build a rgb color' do
        Color.new(['50%','50%','50%']).to_s.should act_like_color_type(RGBcolor, [127,127,127]).to_s
      end
    end
    
    describe 'hsl colors'   
  end   
end