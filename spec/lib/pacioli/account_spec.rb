require 'spec_helper'

describe Pacioli::Account do 
  include Helpers

  before(:each) do
    tear_it_down

    @company = Pacioli::register_company do
      with_name "Coca-Cola"
    end
  end

  context "Create Accounts" do

    it "should be able to create an asset account" do
      account = @company.add_asset_account name: "Accounts Receivable"
      account.should be_asset
    end

    it "should be able to create an equity account" do
      account = @company.add_equity_account name: "Shareholders Capital"
      account.should be_equity
    end

    it "should be able to create a liability account" do
      account = @company.add_liability_account name: "Accounts Payable"
      account.should be_liability
    end

    it "should be able to create an expense account" do
      account = @company.add_expense_account name: "Entertainment"
      account.should be_expense
    end

    it "should be able to create an income account" do
      account = @company.add_income_account name: "Sales"
      account.should be_income
    end

  end
  
end