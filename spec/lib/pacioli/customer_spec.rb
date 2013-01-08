require 'spec_helper'

describe Pacioli::Customer do 
  include Helpers

  before(:each) do
    tear_it_down

    @company = Pacioli::register_company do
      with_name "Coca-Cola"
    end

    @customer = @company.register_customer do
      with_name "Leonardo da Vinci"
    end
  end

  it "should create a customer" do
    Pacioli::Customer.all.count.should == 1
    @customer.name.should == "Leonardo da Vinci"
    @customer.company.should == @company
  end
end