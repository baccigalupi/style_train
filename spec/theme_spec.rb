require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Theme = StyleTrain::Theme unless defined?( Theme )

describe Theme do
  class MyTheme < Theme
    required_keys :foo, :bar
  end
  
  describe 'Theme.required_keys' do
    it 'stores the values' do
      MyTheme.instance_eval('@required_keys').should == [:foo, :bar]
    end
    
    it 'retreives the keys when no argument is supplied' do
      MyTheme.required_keys.should == [:foo, :bar]
    end
  end
  
  describe 'initialize' do
    it 'should work if all the right arguments are provided' do
      lambda { MyTheme.new(:default, :foo => '#666', :bar => 'white') }.should_not raise_error
    end
    
    it 'requires a name' do
      lambda { MyTheme.new(nil, :foo => '#666', :bar => 'white') }.should raise_error( 
        ArgumentError, "Unique name is required as first argument" 
      )
    end
    
    it 'requires a unique name' do
      MyTheme.new(:orange, :foo => 'orange', :bar => 'white')
      lambda{ MyTheme.new(:orange, :foo => 'orange', :bar => 'cream') }.should raise_error(
        ArgumentError, "Unique name is required as first argument"
      )
    end
    
    it 'requires a values hash contains required keys' do
      lambda { MyTheme.new(:red, :foo => 'red') }.should raise_error(
        ArgumentError, "Required keys not provided: :bar"
      )
    end
    
    it 'adds the theme to the themes hash' do
      theme = MyTheme.new(:yellow, :foo => 'lightyellow', :bar => 'white')
      MyTheme.themes[:yellow].should == theme
    end
    
    it 'sets the value hash to value_hash accessor' do
      theme = MyTheme.new(:maroon, :foo => 'maroon', :bar => 'white')
      theme.value_hash.should == Gnash.new({:foo => 'maroon', :bar => 'white'})
    end
  end
  
  describe 'usage' do
    before :all do
      @theme = MyTheme.new(:blue, :foo => 'blue', :bar => 'white', :extra => 'lightyellow')
    end
    
    it 'values can be accessed via []' do
      @theme[:foo].should == 'blue'
      @theme[:bar].should == 'white'
      @theme[:extra].should == 'lightyellow'
    end
    
    it 'values can be set with []=' do
      @theme[:bar] = 'cream'
      @theme[:bar].should == 'cream'
    end
    
    it 'raises an error if a required key is set to nil' do
      lambda{ @theme[:foo] = nil }.should raise_error("Cannot set a required key to nothing")
      lambda{ @theme[:extra] = nil }.should_not raise_error
    end
    
    it 'raises an error if a required key is set to a blank string' do
      lambda{ @theme[:foo] = '' }.should raise_error("Cannot set a required key to nothing")
    end
  end
end