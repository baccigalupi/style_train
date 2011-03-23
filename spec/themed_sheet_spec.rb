require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

ThemedSheet = StyleTrain::ThemedSheet unless defined?( ThemedSheet )

describe ThemedSheet do
  class FooeyTheme < StyleTrain::Theme
    required_keys :foo, :bar
  end
  
  FooeyTheme.new(:default, {
    :foo => '#666',
    :bar => :white
  })
  
  FooeyTheme.new(:inverted, {
    :foo => '#CCC',
    :bar => :black
  })
  
  class FooeySheet <  ThemedSheet
    themes FooeyTheme
    
    def content
      style(:fooey){
        color theme[:foo]
        background :color => theme[:bar]
      }
    end
  end
  
  describe "self.themes" do
    it 'has a setter' do
      ThemedSheet.instance_eval("@themes").should == nil
      ThemedSheet.themes FooeyTheme
      ThemedSheet.instance_eval("@themes").should == FooeyTheme
    end
    
    it 'requires that it be set with a Theme class' do
      lambda{ ThemedSheet.themes String }.should raise_error(
        ArgumentError, "themes must be a StyleTrain::Theme class"
      )
    end
    
    it 'returns the class when no argument is given' do
      ThemedSheet.themes FooeyTheme
      ThemedSheet.themes.should == FooeyTheme
    end
    
    it 'raises an error when no class exists' do
      ThemedSheet.instance_eval "@themes = nil"
      lambda{ ThemedSheet.themes }.should raise_error( 
        ArgumentError, "No themes class is defined. Please add one with the class method #themes"
      )
    end
  end
  
  describe '#theme' do
    before :all do
      @sheet = FooeySheet.new
    end
    
    it 'throws an error if a theme class is not defined' do
      ThemedSheet.instance_eval "@themes = nil"
      sheet = ThemedSheet.new
      lambda {sheet.theme}.should raise_error(
        ArgumentError, "No themes class is defined. Please add one with the class method #themes"
      )
    end
    
    it 'will get the default theme if none is found' do
      @sheet.theme.should == FooeyTheme.themes[:default]
    end
    
    it 'can be set via any name in the theme class' do
      @sheet.theme = :inverted
      @sheet.theme.should == FooeyTheme.themes[:inverted]
    end
    
    it 'will raise an error if the name is not found in the class' do
      lambda{ @sheet.theme = :not_in_fooey }.should raise_error(
        ArgumentError, "Theme :not_in_fooey not found in FooeyTheme"
      )
    end
  end
  
  describe 'export' do
    before :all do
      @dir = File.dirname(__FILE__) + "/generated_files"
      StyleTrain.dir = @dir
      Dir.chdir(@dir)
    end
    
    before do
      Dir.glob('*.css').each do |file|
        File.delete(file)
      end
    end
    
    it 'exports a file for each theme in the theme class' do
      Dir.glob('*.css').size.should == 0
      FooeySheet.export
      Dir.glob('*.css').size.should == 2
    end
    
    it 'uses the theme name when constructing the css file name' do
      FooeySheet.export
      File.exist?(@dir + '/fooey_sheet_default.css').should == true
      File.exist?(@dir + '/fooey_sheet_inverted.css').should == true
    end
  end
end