require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Cohuman < StyleTrain::Sheet
  def content
    body {
      font :size => 13.px, :family => "Verdana Sans", :height => 1.5
    }
    
    h1 { font :size => 25.px}
    h2 { font :size => 23.px}
    h3 { font :size => 18.px}
    h3 { margin 0 }
    h4 { font :size => 16.px}
    h5 { font :size => 11.px}
    h6 { font :size => 10.px}
    
    hr {
      border :none
      height 1.px
      color :gray
      background :color => :gray
    }
    
    c(:create_button) {
      font :weight => :bold, :size => 8.em
      border :color => :black
      color :gray
      cursor :pointer
      padding 0, 0.5.em
    }
    
    c(:activity_button) {
    	display 'inline-block'
    	position :relative
    	overflow :visible
    	padding 0
    	font :weight => :bold, :size => 0.8.em
    	cursor :pointer
    	color :gray
    	border :color => :black
    }
    
    c(:user_info) { 
    	padding 10.px, 10.px, 0.px, 10.px
    	width 500.px;
    	overflow :x => :hidden
    	
    	h1 {
    	  margin -4.px, 0, -2.px, 0
    	  font :size => 1.5.em
    	}
    	
    	c(:my_class){
    	  padding 2.em
    	}
    	
    	c('< p'){
    	  padding 1.em
    	}
    }
  end
end

@dir = File.dirname(__FILE__) + "/generated_files"
StyleTrain.dir = @dir
Cohuman.export