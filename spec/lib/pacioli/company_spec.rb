require 'spec_helper'
require 'ostruct'

describe Pacioli::Company do 
  include Helpers

  before(:each) do
    tear_it_down

    @company = Pacioli::register_company do
      with_name "Coca-Cola"
    end
  end

  it "should create a company" do
    Pacioli::Company.all.count.should == 1
    Pacioli::Company.first.name.should == "Coca-Cola"
  end
  
end