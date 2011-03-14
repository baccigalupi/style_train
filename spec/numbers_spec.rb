require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Fixnum do
  it '#em converts to a string with em at the end' do
    42.em.should == '42em'
  end
  
  it '#px converts to a string with px at the end' do
    42.px.should == '42px'
  end
  
  it '#percent converts to a string with % at the end' do
    42.percent.should == '42%'
  end
  
  it '#pt converts to a string with % at the end' do
    42.pt.should == '42pt'
  end
  
  it '#degrees converts to a snring with degrees at the end' do
    42.degrees.should == '42degrees'
  end
end

describe Float do
  it '#em converts to a string with em at the end' do
    1.5.em.should == '1.5em'
  end
  
  it '#pt converts to a string with pt at the end' do
    12.5.pt.should == '12.5pt'
  end
  
  it '#percent converts to a string with % at the end' do
    30.25.percent.should == '30.25%'
  end
  
  it '#degrees converts to a snring with degrees at the end' do
    42.5.degrees.should == '42.5degrees'
  end
end