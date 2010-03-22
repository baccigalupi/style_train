require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Color = StyleTrain::Color unless defined?(Color)

describe Color do
  before do
    pending
  end
  
  def build_color( color_class, args ) 
    color_class.new(:color => args)
  end   
   
  describe 'initialization' do
    describe 'sets a delegate' do
      describe 'with a keyword argument' do
        it 'should build an html keyword color' do
          Color.new("gray").should build_color(KeywordColor, 'gray')
        end 

        it 'should build a svg keyword color' do 
          Color.new(:linen).should build_color(KeywordColor, :linen)
        end
      end   
 
      describe 'with a hex string argument' do
        it '(3-digit no #) should build a hex color' do 
          Color.new('333').should build_color(HexColor, '333')
        end
      
        it '(3-digit with #) should build a hex color' do 
          Color.new('#333').should build_color(HexColor, '#333')
        end
      
        it '(6-digit no #) should build a hex color' do  
          Color.new('333333').should build_color(HexColor, '333333')
        end
      
        it '(6-digit with #) should build a hex color' do
          Color.new('#333333').should build_color(HexColor, '#333333')
        end
      end
 
      describe 'with an rgb array argument' do
        it '(with a byte array) should build a rgb color' do
          Color.new([127,127,127]).should build_color(RGBcolor, [127,127,127])
        end
      
        it '(with a percentage array) should build a rgb color' do
          Color.new(['50%','50%','50%']).should build_color(RGBcolor, [127,127,127])
        end
      end
    
      describe 'hsl colors' 
    end    
  end   
end