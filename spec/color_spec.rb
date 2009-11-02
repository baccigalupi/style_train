require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "StyleTrain::Color" do
  @color_types = { 
      'html keywords' => ["gray"],  
      'svg keywords' =>  ['linen', 'rgba( 250, 240, 230, 1.0 )'],
      '3-digit hex string' => ['666'], 
      '3-digit hex string with pound' => ["#666"], 
      '6-digit hex string' => ["666666"],
      '6-digit hex string with pound' => ['#666666'],
      'rgb percentage array' => [ [127,127,127] ],
      'rgb 0-255 array' => [ ['50%','50%','50%'] ],
      'hsl percentages array' => [ [0, 0, 127] ],
      'hsl 0-255 array' => [ ['0%', '0%', '50%'] ]
   } 
   
   @color_types.each do |color_type, value| 
     @opts = color_type.match(/hsl/) ? {:hsl => true} : {}
     it "should load the right color from #{color_type}" do
       Color.new( value[0], @opts  ).to_s should == ( value[1] || "rgba( 127, 127, 127, 1.0 )" )
     end  
   end  
 
en