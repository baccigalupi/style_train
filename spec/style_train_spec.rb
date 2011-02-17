require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe StyleTrain, 'configuration' do
  it 'has a css directory' do
    StyleTrain.dir = '/foo'
    StyleTrain.dir.should == '/foo'
  end
end