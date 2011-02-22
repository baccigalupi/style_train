require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Theme = StyleTrain::Theme unless defined?( Theme )

describe Theme do
  class MyTheme < Theme
    required_keys :foo, :bar, :zardoz
    defaults :zardoz => 'sexy'
  end
  
  describe 'requiring keys' do
    describe '#require_keys' do
      it 'stores the values' do
        MyTheme.instance_eval('@required_keys').should == [:foo, :bar, :zardoz]
      end
    
      it 'retreives the keys when no argument is supplied' do
        MyTheme.required_keys.should == [:foo, :bar, :zardoz]
      end
    end
    
    describe '#defaults' do
      before :all do
        @theme = MyTheme.new(:orange_red, :foo => 'orange', :bar => 'white')
      end
      
      it 'store the values' do
        MyTheme.instance_eval('@defaults').should == Gnash.new(:zardoz => 'sexy')
      end
      
      it 'retrieves the hash when called without an argument' do
        MyTheme.defaults.should == Gnash.new(:zardoz => 'sexy')
      end
      
      it 'adds defaults to the value hash' do
        @theme[:zardoz].should == 'sexy'
      end
      
      it 'does not override values with the same key' do
        theme = MyTheme.new(:red_orange, :foo => 'red', :bar => 'white', :zardoz => 'not all that')
        theme[:zardoz].should == 'not all that'
      end
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
      theme.value_hash.should == Gnash.new({:foo => 'maroon', :bar => 'white', :zardoz => 'sexy'})
    end
    
    describe 'with palette' do
      before :all do
        @theme = MyTheme.new(:substitutor, {:foo => :blue, :bar => :white}, {:blue => 'true blue', :white => 'off sometimes'})
      end
      
      it "will save the pallete when it finds that argument" do
        @theme.palette.should == {:blue => 'true blue', :white => 'off sometimes'}
      end
      
      it 'will substitue symbols for pallete values with the same key' do
        @theme.value_hash.should == Gnash.new({:foo => 'true blue', :bar => 'off sometimes', :zardoz => 'sexy'})
      end
    end
  end
  
  describe 'class helpers' do
    before :all do
      @theme = MyTheme.new(:pink, :foo => 'pink', :bar => 'white')
    end
    
    it 'returns can access themes via []' do
      MyTheme[:pink].should == @theme
    end
    
    it 'has theme keys' do
      MyTheme.keys.should include :pink
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