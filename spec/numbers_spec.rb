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
end

describe Float do
  it '#em converts to a string with em at the end' do
    1.5.em.should == '1.5em'
  end
end