require 'spec_helper'

describe SagePay do
  it "should be version 0.2.5" do
    SagePay::VERSION.should == '0.2.5'
  end
end