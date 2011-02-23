require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Sheet = StyleTrain::Sheet unless defined?( Sheet )

describe Sheet do
  describe 'attributes' do
    before :all do
      @sheet = Sheet.new
    end
    
    it 'should have an output' do
      @sheet.output = 'foo'
      @sheet.output.should == 'foo'
    end
    
    it 'output gets set to an empty string on initialize' do
      Sheet.new.output.should == ''
    end
    
    it 'should have an indent_level that is initialized to 0' do
      Sheet.new.indent_level.should == 0
    end
  end
  
  describe '#render' do
    before :all do
      @sheet = Sheet.new
    end
    
    it 'resets the output' do
      @sheet.should_receive(:output=).with('')
      @sheet.render
    end
    
    it 'calls #content by default' do
      @sheet.should_receive(:content)
      @sheet.render
    end
    
    it 'calls an alterate content method' do
      @sheet.should_not_receive(:content)
      @sheet.should_receive(:foo)
      @sheet.render :foo
    end
    
    it 'returns the output' do
      @sheet.output = "bar"
      @sheet.stub(:output=)
      @sheet.stub(:content).and_return('foo')
      @sheet.render.should == "bar"
    end
  end
  
  describe '#style' do
    before do
      @sheet = Sheet.new
    end
    
    it 'adds an entry to the output' do
      @sheet.output.should == ""
      @sheet.style(:foo)
      @sheet.output.should_not == ""
    end
    
    it 'renders the right style when passed a string' do
      @sheet.style('.foo')
      @sheet.output.should include '.foo'
    end
    
    it 'renders the right selecter when passed a non-tag symbol' do
      @sheet.style(:bar)
      @sheet.output.should include '.bar'
    end
    
    it 'renders the right style when passed a tag symbol' do
      @sheet.style(:body)
      @sheet.output.should include 'body'
      @sheet.output.should_not include '.body'
    end
    
    it 'renders {} when not passed a block' do
      @sheet.style(:body)
      @sheet.output.should include "body {\n}"
    end
    
    describe 'receiving a block' do
    end
    
    describe 'nesting' do
    end
  end
  
  describe 'tags' do
    before do
      @sheet = Sheet.new
    end
    
    Sheet::TAGS.each do |tag|
      it "should have a method for '#{tag}'" do
        @sheet.should respond_to(tag)
      end
      
      it "should add a style for '#{tag}'" do
        @sheet.send(tag)
        @sheet.output.should include "#{tag} {\n}"
      end
    end
    
    it 'should pass the block on to the style method' do
      str = @sheet.instance_eval <<-RUBY
        body do
          margin [2.em, :auto]
        end
      RUBY
      str.should include 'margin: 2em auto'
    end
  end
  
  describe 'properties' do
    before :all do
      @sheet = Sheet.new
    end
    
    describe '#property' do
      before :all do
        @sheet.indent_level = 4
        @property = @sheet.property('border', '1px solid #ccc' )
      end
      
      it 'returns a string' do
        @property.is_a?(String).should be_true
      end
      
      it 'adds a line break and an indent to the front of the string' do
        @property.match(/^\W{5}/).should_not be_nil
      end
      
      it 'includes the property name' do
        @property.should include 'border'
      end
      
      it 'includes punctuation' do
        @property.should include ':', ';'
      end
      
      it 'includes the value' do
        @property.should include '1px solid #ccc'
      end
      
      it 'puts it all together correctly' do
        @property.should == "\n    border: 1px solid #ccc;"
      end
      
      it 'adds the string to the output' do
        @sheet.output.should include @property
      end
      
      it 'converts an array to a space separated string' do
        @sheet.property('margin', [0,0,0,0]).should include '0 0 0 0'
      end
    end
    
    describe 'background' do
      it ':color will create a background-color property' do
        @sheet.background(:color => :white).should include 'background-color: white;'
      end
      
      it ':image will create a background-image property' do
        @sheet.background(:image => "url('ok.png')").should include "background-image: url('ok.png');"
      end
      
      it ':position will create a background-position property' do
        @sheet.background(:position => "center").should include 'background-position: center;'
      end
      
      it ':attachment will create a background-attachment property' do
        @sheet.background(:attachment => 'fixed').should include 'background-attachment: fixed;'
      end
      
      it ':repeat will create a background-repeat property with the correct value' do
        @sheet.background(:repeat => :x).should include "background-repeat: repeat-x;"
      end
      
      it 'will create a background-color property if it receives a string that converts to a color' 
      it 'will create a background-color property if it receives a color'
    end
    
    describe 'border' do
      it 'it defaults to 1px solid black' do
        @sheet.border.should include 'border: 1px solid black;'
      end
      
      it 'takes the width it is passed in' do
        @sheet.border(:width => 3.px).should include 'border: 3px solid black;'
      end
      
      it 'takes in the color when it is passed in' do
        @sheet.border(:color => StyleTrain::Color.new('#333')).should include 'border: 1px solid #333'
      end
      
      it 'takes in the style when it is passed in' do
        @sheet.border(:style => 'dashed').should include 'border: 1px dashed black'
      end

      it 'makes a declaration for only a certain type of border when requested' do
        @sheet.border(:only => :bottom).should include 'border-bottom: 1px solid black'
      end
      
      it ':only option works as an array too' do
        @sheet.border(:only => [:bottom, :left]).should include( 
          'border-bottom: 1px solid black', 'border-left: 1px solid black'
        )
      end
    end
    
    describe 'outline' do
      it 'it defaults to 1px solid black' do
        @sheet.outline.should include 'outline: 1px solid black;'
      end
      
      it 'takes the width it is passed in' do
        @sheet.outline(:width => 3.px).should include 'outline: 3px solid black;'
      end
      
      it 'takes in the color when it is passed in' do
        @sheet.outline(:color => StyleTrain::Color.new('#333')).should include 'outline: 1px solid #333'
      end
      
      it 'takes in the style when it is passed in' do
        @sheet.outline(:style => 'dashed').should include 'outline: 1px dashed black'
      end
    end
    
    describe 'dimensions' do
      describe '#height' do
        it 'makes a height declaration' do
          @sheet.height(320.px).should include 'height: 320px;'
        end
      
        it 'will make a max declaration too' do
          @sheet.max_height(400.px).should include 'max-height: 400px'
        end
        
        it 'will make a min width declaration' do
          @sheet.min_height(200.px).should include 'min-height: 200px'
        end
      end
      
      describe '#height' do
        it 'makes a height declaration' do
          @sheet.width(320.px).should include 'width: 320px;'
        end
      
        it 'will make a max declaration too' do
          @sheet.max_width(400.px).should include 'max-width: 400px'
        end
        
        it 'will make a min width declaration' do
          @sheet.min_width(200.px).should include 'min-width: 200px'
        end
      end
    end
    
    describe 'position' do
      it 'takes a string argument and makes a position declaration' do
        @sheet.position( 'absolute' ).should include 'position: absolute'
      end
      
      it 'take a symbol and makes a position declaration' do
        @sheet.position( :relative ).should include 'position: relative'
      end
      
      it 'takes a option for type and makes a position declaration' do
        @sheet.position(:type => :fixed).should include 'position: fixed'
      end
      
      it 'makes a bottom declaration' do
        @sheet.position(:bottom => 5.px).should include 'bottom: 5px'
      end
      
      it 'makes a right declaration' do
        @sheet.position(:right => 15.px).should include 'right: 15px'
      end
      
      it 'makes a top declaration' do
        @sheet.position(:top => 25.px).should include 'top: 25px'
      end
      
      it 'makes a left declaration' do
        @sheet.position(:left => 35.px).should include 'left: 35px'
      end
      
      it 'floats' do
        @sheet.position(:float => :left).should include 'float: left'
      end
      
      it 'clears' do
        @sheet.position(:clear => :both).should include 'clear: both'
      end
      
      it 'has a display declaration' do
        @sheet.position(:display => :inline).should include 'display: inline'
      end
      
      it 'constructs visibility' do
        @sheet.position(:visibility => :hidden).should include 'visibility: hidden'
      end
      
      it 'has a z-index' do
        @sheet.position(:z_index => 5).should include 'z-index: 5'
      end
      
      it 'has overflow declarations' do
        @sheet.position(:overflow => :scroll).should include 'overflow: scroll'
        @sheet.position(:overflow_x => :hidden).should include 'overflow-x: hidden'
        @sheet.position(:overflow_y => :visible).should include 'overflow-y: visible'
      end
      
      it 'has a clip declaration' do
        @sheet.position(:clip => [10.px, 20.px, 30.px, 40.px]).should include 'clip: rect(10px 20px 30px 40px)'
      end
    end

    describe 'text' do
      it 'adds a font-family declaration when passed a font option' do
        @sheet.text(:font => 'arial').should include 'font-family: arial;'
      end
      
      it 'adds a font-size declaration whet passed' do
        @sheet.text(:size => 23.pt).should include 'font-size: 23pt;'
      end
      
      it 'adds a style declaration' do
        @sheet.text(:style => :italic).should include 'font-style: italic;'
      end
      
      it 'adds a variant declaration' do
        @sheet.text(:variant => 'small-caps').should include 'font-variant: small-caps;'
      end
      
      it 'adds a weight declaration' do
        @sheet.text(:weight => 'bold').should include 'font-weight: bold;'
      end
      
      it 'adds color' do
        @sheet.text(:color => '#444').should include 'color: #444;'
      end
      
      it 'adds direction' do
        @sheet.text(:direction => :rtl).should include 'text-direction: rtl'
      end
      
      it 'adds letter spacing' do
        @sheet.text(:spacing => -2.px).should include 'letter-spacing: -2px'
      end
      
      it 'adds line height' do
        @sheet.text(:line_height => 2).should include 'line-height: 2'
      end
      
      it 'aligns' do
        @sheet.text(:align => :center).should include 'text-align: center'
      end
      
      it 'adds decoration' do
        @sheet.text(:decoration => :underline).should include 'text-decoration: underline'
      end
      
      it 'indents' do
        @sheet.text(:indent => 20.px).should include 'text-indent: 20px'
      end
      
      it 'adds a transform' do
        @sheet.text(:transform => :uppercase).should include 'text-transform: uppercase'
      end
      
      it 'adds a vertical align' do
        @sheet.text(:vertical_align => :top).should include 'vertical-align: top'
      end
      
      it 'adds white space declaration' do
        @sheet.text(:white_space => :nowrap).should include 'white-space: nowrap'
      end
      
      it 'specifies word spacing' do
        @sheet.text(:word_spacing => 25.px).should include 'word-spacing: 25px'
      end
    end
    
    describe 'list' do
      it 'sets the image' do
        @sheet.list(:image => 'url("foo.gif")').should include 'list-style-image: url("foo.gif")'
      end
      
      it 'sets the position' do
        @sheet.list(:position => :inside).should include 'list-style-position: inside'
      end
      
      it 'sets the type' do
        @sheet.list(:type => :square).should include 'list-style-type: square'
      end
    end
    
    describe 'margin' do
      it 'takes an array' do
        @sheet.margin( [10.px, 20.px, 13.px] ).should include 'margin: 10px 20px 13px'
      end
      
      it 'takes :left and just makes that declaration' do
        @sheet.margin( :left => 30.px ).should include 'margin-left: 30px'
      end
      
      it 'takes :left and just makes that declaration' do
        @sheet.margin( :right => 20.px ).should include 'margin-right: 20px'
      end
      
      it 'takes :left and just makes that declaration' do
        @sheet.margin( :top => 10.px ).should include 'margin-top: 10px'
      end
      
      it 'takes :left and just makes that declaration' do
        @sheet.margin( :bottom => 15.px ).should include 'margin-bottom: 15px'
      end
    end
    
    describe 'padding' do
      it 'takes an array' do
        @sheet.padding( [10.px, 20.px, 13.px] ).should include 'padding: 10px 20px 13px'
      end
      
      it 'takes :left and just makes that declaration' do
        @sheet.padding( :left => 30.px ).should include 'padding-left: 30px'
      end
      
      it 'takes :left and just makes that declaration' do
        @sheet.padding( :right => 20.px ).should include 'padding-right: 20px'
      end
      
      it 'takes :left and just makes that declaration' do
        @sheet.padding( :top => 10.px ).should include 'padding-top: 10px'
      end
      
      it 'takes :left and just makes that declaration' do
        @sheet.padding( :bottom => 15.px ).should include 'padding-bottom: 15px'
      end
    end
    
    describe 'table_options' do
      it 'has border option' do
        @sheet.table_options(:border => :collapse).should include 'border-collapse: collapse'
      end
      
      it 'border spacing option' do
        @sheet.table_options(:border_spacing => [20.px, 30.px]).should include 'border-spacing: 20px 30px'
      end
      
      it 'has a caption option' do
        @sheet.table_options(:caption => :bottom).should include 'caption-side: bottom'
      end
      
      it 'has empty option' do
        @sheet.table_options(:empty => :hide).should include 'empty-cells: hide'
      end
      
      it 'has a layout' do
        @sheet.table_options(:layout => :fixed).should include 'table-layout: fixed'
      end
    end
    
    describe 'print' do
      #  orphans  Sets the minimum number of lines that must be left at the bottom of a page when a page break occurs inside an element 2
      #  page-break-after Sets the page-breaking behavior after an element  2
      #  page-break-before  Sets the page-breaking behavior before an element 2
      #  page-break-inside  Sets the page-breaking behavior inside an element 2
      #  widows Sets the minimum number of lines that must be left at the top of a page when a page break occurs inside an element	2
    end
    
    describe 'misc' do
      # content Used with the :before and :after pseudo-elements, to insert generated content 2
      # counter-increment Increments one or more counters 2
      # counter-reset Creates or resets one or more counters  2
      # quotes  Sets the type of quotation marks for embedded quotations  2
      # cursor  Specifies the type of cursor to be displayed  2
      it 'has a cursor declaration' do
        @sheet.cursor(:crosshair).should include 'cursor: crosshair'
      end
    end
    
    describe 'duplicate declarations' do
      it 'color' do
        @sheet.color(StyleTrain::Color.new('#456')).should include 'color: #456'
      end
      
      it 'overflows' do
        @sheet.overflow(:hidden).should include 'overflow: hidden'
        @sheet.overflow(:x => :scroll).should include 'overflow-x: scroll'
        @sheet.overflow(:y => :auto).should include 'overflow-y: auto'
      end
      
      it 'display' do
        @sheet.display(:block).should include 'display: block'
      end
      
      it 'float' do
        @sheet.float(:left).should include 'float: left'
      end
      
      it 'clear' do
        @sheet.clear(:both).should include 'clear: both'
      end
      
      it 'visibility' do
        @sheet.visibility(:hidden).should include 'visibility: hidden'
      end
    end
  end
  
  describe 'css 3 goodies' do
    before :all do
      @sheet = Sheet.new
    end
    
    describe '#corners' do
      it 'makes all corners the specified roundness' do
        str = @sheet.corners(32.px)
        str.should include "border-radius: 32px"
        str.should include "-moz-border-radius: 32px"
        str.should include "-webkit-border-radius: 32px"
      end
      
      it '#corner_top_left make the correct three declarations' do
        str = @sheet.corner_top_left(1.em)
        str.should include( 
          "border-top-left-radius: 1em", 
          "-moz-border-radius-topleft: 1em", 
          "-webkit-border-top-left-radius: 1em"
        )  
      end
      
      it '#corners makes a top left corner' do
        @sheet.corners(:top_left => 2.em).should == @sheet.corner_top_left(2.em)
      end
      
      it '#corner_top_right make the correct three declarations' do
        str = @sheet.corner_top_right(1.5.em)
        str.should include( 
          "border-top-right-radius: 1.5em", 
          "-moz-border-radius-topright: 1.5em", 
          "-webkit-border-top-right-radius: 1.5em"
        )  
      end
      
      it '#corners makes a top left corner' do
        @sheet.corners(:top_right => 1.em).should == @sheet.corner_top_right(1.em)
      end
      
      
      it '#corner_bottom_right make the correct three declarations' do
        str = @sheet.corner_bottom_right(1.5.em)
        str.should include( 
          "border-bottom-right-radius: 1.5em", 
          "-moz-border-radius-bottomright: 1.5em", 
          "-webkit-border-bottom-right-radius: 1.5em"
        )  
      end
      
      it '#corners makes a top right corner' do
        @sheet.corners(:bottom_right => 1.em).should == @sheet.corner_bottom_right(1.em)
      end
      
      it '#corner_bottom_left make the correct three declarations' do
        str = @sheet.corner_bottom_left(1.5.em)
        str.should include( 
          "border-bottom-left-radius: 1.5em", 
          "-moz-border-radius-bottomleft: 1.5em", 
          "-webkit-border-bottom-left-radius: 1.5em"
        )  
      end
      
      it '#corners makes a top left corner' do
        @sheet.corners(:bottom_left => 1.em).should == @sheet.corner_bottom_left(1.em)
      end
      
      it 'makes both top corners at once' do
        str = @sheet.corners(:top => 20.px)
        str.should include "border-top-left-radius: 20px"
        str.should include "-moz-border-radius-topleft: 20px"
        str.should include "-webkit-border-top-left-radius: 20px"
        str.should include "border-top-right-radius: 20px"
        str.should include "-moz-border-radius-topright: 20px"
        str.should include "-webkit-border-top-right-radius: 20px"
      end
      
      it 'makes both bottom corners at once' do
        str = @sheet.corners(:bottom => 30.px)
        str.should include "border-bottom-left-radius: 30px"
        str.should include "-moz-border-radius-bottomleft: 30px"
        str.should include "-webkit-border-bottom-left-radius: 30px"
        str.should include "border-bottom-right-radius: 30px"
        str.should include "-moz-border-radius-bottomright: 30px"
        str.should include "-webkit-border-bottom-right-radius: 30px"
      end
      
      it 'makes both left corners at once' do
        str = @sheet.corners(:left => 10.px)
        str.should include "border-bottom-left-radius: 10px"
        str.should include "-moz-border-radius-bottomleft: 10px"
        str.should include "-webkit-border-bottom-left-radius: 10px"
        str.should include "border-top-left-radius: 10px"
        str.should include "-moz-border-radius-topleft: 10px"
        str.should include "-webkit-border-top-left-radius: 10px"
        
      end
      
      it 'makes both right corners at once' do
        str = @sheet.corners(:left => 15.px)
        str.should include "border-bottom-left-radius: 15px"
        str.should include "-moz-border-radius-bottomleft: 15px"
        str.should include "-webkit-border-bottom-left-radius: 15px"
        str.should include "border-top-left-radius: 15px"
        str.should include "-moz-border-radius-topleft: 15px"
        str.should include "-webkit-border-top-left-radius: 15px"
      end
    end
    
    describe '#shadow' do
      it 'build declarations for all three browser types' do
        str = @sheet.shadow
        str.should match(/^box-shadow/)
        str.should include '-webkit-box-shadow'
        str.should include '-moz-box-shadow'
      end
      
      it 'has good defaults' do
        @sheet.shadow.should include "0.25em 0.25em 0.25em black"
      end
      
      it 'uses the color when provided' do
        str = @sheet.shadow(:color => '#666')
        str.should include '#666'
        str.should_not include 'black'
      end
      
      it 'uses the horizontal offset when provided' do
        @sheet.shadow(:horizontal_offset => 20.px).should include "20px 0.25em 0.25em black"
      end
      
      it 'uses the vertical offset when provided' do
        @sheet.shadow(:vertical_offset => 10.px).should include "0.25em 10px 0.25em black"
      end
      
      it 'uses the blur when provided' do
        @sheet.shadow(:blur => 15.px).should include "0.25em 0.25em 15px black"
      end
      
      it 'will make an inner shadow' do
        @sheet.shadow(:inner => true).should include "inset 0.25em 0.25em 0.25em black"
      end
    end
    
    describe 'gradient' do
      it 'requires a start and end color' do
        lambda{ @sheet.gradient }.should raise_error(ArgumentError, "gradient styles require a :start and :end color")
      end
      
      it 'builds the necessary declarations' do
        @sheet.gradient(:start => :white, :end => :black).should include(
          "background: black",
          "background: -webkit-gradient",
          "background: -moz-linear-gradient"
        )
      end
      
      describe 'direction' do
        it 'defaults from top to bottom' do
          @sheet.gradient(:start => :white, :end => :black).should include( 
            "linear, left top, left bottom", 
            "linear-gradient(top"
          )
        end
        
        it 'makes from left to right' do
          @sheet.gradient(:start => :white, :end => :black, :from => :left).should include(
            "linear, left top, right top",
            "linear-gradient(left" 
          )
        end
      end
    end
  end

  class StyleSheet < StyleTrain::Sheet
    def content
      body { 
        background :color => '#666'
        text :font => 'verdana' 
      }
      
      style('#wrapper'){
        background :color => :white
        margin [1.em, :auto]
      }
    end
  end
  
  describe 'subclassing' do
    it 'works' do
      StyleSheet.render.should include( 
<<-CSS
body {
  background-color: #666;
  font-family: verdana;
}

#wrapper {
  background-color: white;
  margin: 1em auto;
}
CSS
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
    
    it 'exports to the StyleTrain dir location' do
      StyleSheet.export
      Dir.glob('*.css').size.should == 1
    end
    
    it 'uses the class name underscored by default' do
      StyleSheet.export
      File.exist?(@dir + '/style_sheet.css').should == true
    end
    
    it 'uses an alternate name when provided' do
      StyleSheet.new.export(:file_name => 'foo')
      File.exists?(@dir + 'foo')
    end
  end
end
