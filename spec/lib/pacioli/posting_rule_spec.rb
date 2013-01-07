require 'spec_helper'

describe Pacioli::Account do 
  include Helpers

  before(:each) do
    tear_it_down

    @company = Pacioli::register_company do
      with_name "Coca-Cola"
      add_asset_account name: "Accounts Receivable", code: "100"
      add_income_account name: "Sales", code: "301"
    end

    @posting_rule = @company.create_posting_rule do
      with_name :sale
      debit "Accounts Receivable"
      credit "Sales"
    end
  end

  it "should store the rules" do
    @posting_rule.rules.should == {
      credits: [
        {account: "Sales", percentage: 100}
      ],
      debits: [
        {account: "Accounts Receivable", percentage: 100}
      ]
    }

    @posting_rule.name.should == :sale
  end

  it "should be balanced" do
    @posting_rule.should be_balanced
  end

  it "should be whole" do
    @posting_rule.should be_whole
  end

end