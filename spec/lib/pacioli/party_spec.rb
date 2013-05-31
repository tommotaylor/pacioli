require 'spec_helper'

describe Pacioli::Party do 
  include Helpers

  before(:each) do
    tear_it_down

    @company = Pacioli::register_company do
      with_name "Coca-Cola"

      add_asset_account name: "Accounts Receivable", code: "100"
      add_asset_account name: "Cash in Bank", code: "101"
      add_income_account name: "Sales", code: "301"
      add_liability_account name: "Sales Tax", code: "401"
    end

    @debtor = @company.register_debtor do
      with_name "Leonardo da Vinci"
    end
  end

  it "should create a debtor" do
    @company.debtors.count.should == 1
    Pacioli::Debtor.all.count.should == 1
    @debtor.name.should == "Leonardo da Vinci"
    @debtor.company.should == @company
  end

  context "Debtors Statement for past 11 weeks" do

    before(:each) do
      debtor = @debtor

      debit_entries = [
        {description: "Invoice 123 for Rent #{Date.today - 12.weeks}", dated: Date.today - 12.weeks, source: debtor, amt: 5000.00, against: debtor},
        {description: "Invoice 124 for Rent #{Date.today - 8.weeks}", dated: Date.today - 8.weeks, source: debtor, amt: 2000.00, against: debtor},
        {description: "Invoice 125 for Rent #{Date.today - 4.weeks}", dated: Date.today - 4.weeks, source: debtor, amt: 3000.00, against: debtor},
        {description: "Invoice 126 for Fee #{Date.today - 2.weeks}", dated: Date.today - 2.weeks, source: debtor, amt: 4000.00, against: debtor}
      ]

      credit_entries = [
        {description: "PMT Received for Invoice 123 #{Date.today - 7.weeks}", dated: Date.today - 7.weeks, source: debtor, amt: 5000.00, against: debtor},
        {description: "PMT Received for Invoice 123 #{Date.today - 3.weeks}", source: debtor, dated: Date.today - 3.weeks, amt: 2000.00, against: debtor},
      ]

      credit_entries.each do |credit_entry|
        @company.record_journal_entry do
          with_description credit_entry[:description]
          with_source_document credit_entry[:source]
          with_date credit_entry[:dated]

          debit account: "Cash in Bank", amount: credit_entry[:amt]
          credit account: "Accounts Receivable", amount: credit_entry[:amt], against_party: credit_entry[:against]
        end
      end

      debit_entries.each do |debit_entry|
        @company.record_journal_entry do
          with_description debit_entry[:description]
          with_source_document debit_entry[:source]
          with_date debit_entry[:dated]

          debit account: "Accounts Receivable", amount: debit_entry[:amt], against_party: debit_entry[:against]
          credit account: "Sales", amount: debit_entry[:amt]
        end
      end

      @statement = @debtor.statement_between_dates(Date.today - 11.weeks, Date.today)
    end

    it "should have an opening balance of 5000.00" do
      @statement.first[:balance].should == 5000.00
    end

    it "should have 3 debit entries to the value of 9000.00" do
      @statement.select {|entry| !entry[:debit_amount].blank?}.count.should == 3
      @statement.select {|entry| !entry[:debit_amount].blank?}.map {|i| i[:debit_amount]}.sum().should == 9000.00
    end

    it "should have a closing balance of 7000.00" do
      @statement.last[:balance].should == 7000.00
    end

  end

  context "Debtors Age Analysis Report" do
    before(:each) do
      debtor = @debtor

      debit_entries = [
        {description: "Invoice 119 for Rent #{Date.today - 22.weeks}", dated: Date.today - 22.weeks, source: debtor, amt: 5500.00, against: debtor},
        {description: "Invoice 120 for Rent #{Date.today - 18.weeks}", dated: Date.today - 18.weeks, source: debtor, amt: 3000.00, against: debtor},
        {description: "Invoice 121 for Rent #{Date.today - 14.weeks}", dated: Date.today - 14.weeks, source: debtor, amt: 300.00, against: debtor},
        {description: "Invoice 123 for Rent #{Date.today - 12.weeks}", dated: Date.today - 12.weeks, source: debtor, amt: 10000.00, against: debtor},
        {description: "Invoice 124 for Rent #{Date.today - 8.weeks}", dated: Date.today - 8.weeks, source: debtor, amt: 2000.00, against: debtor},
        {description: "Invoice 125 for Rent #{Date.today - 4.weeks}", dated: Date.today - 4.weeks, source: debtor, amt: 3000.00, against: debtor},
        {description: "Invoice 126 for Fee #{Date.today - 2.weeks}", dated: Date.today - 2.weeks, source: debtor, amt: 4000.00, against: debtor}
      ]

      credit_entries = [
        {description: "PMT Received for Invoice 123 #{Date.today - 20.weeks}", dated: Date.today - 20.weeks, source: debtor, amt: 5500.00, against: debtor},
        {description: "PMT Received for Invoice 123 #{Date.today - 15.weeks}", source: debtor, dated: Date.today - 15.weeks, amt: 3000.00, against: debtor},
        {description: "PMT Received for Invoice 123 #{Date.today - 7.weeks}", dated: Date.today - 7.weeks, source: debtor, amt: 5000.00, against: debtor},
        {description: "PMT Received for Invoice 123 #{Date.today - 3.weeks}", source: debtor, dated: Date.today - 3.weeks, amt: 2000.00, against: debtor},
      ]

      credit_entries.each do |credit_entry|
        @company.record_journal_entry do
          with_description credit_entry[:description]
          with_source_document credit_entry[:source]
          with_date credit_entry[:dated]

          debit account: "Cash in Bank", amount: credit_entry[:amt]
          credit account: "Accounts Receivable", amount: credit_entry[:amt], against_party: credit_entry[:against]
        end
      end

      debit_entries.each do |debit_entry|
        @company.record_journal_entry do
          with_description debit_entry[:description]
          with_source_document debit_entry[:source]
          with_date debit_entry[:dated]

          debit account: "Accounts Receivable", amount: debit_entry[:amt], against_party: debit_entry[:against]
          credit account: "Sales", amount: debit_entry[:amt]
        end
      end

      @age_analysis = @debtor.age_analysis_report
    end

    it "should have a balance of 3000.00 on 120 days" do
      @age_analysis.select{|item| item[:description] == "120 Days"}.first[:balance].to_s.should == "3000.0"
    end

    it "should have a balance of 300.00 on 90 days" do
      @age_analysis.select{|item| item[:description] == "90 Days"}.first[:balance].to_s.should == "300.0"
    end

    it "should have a balance of 10300.00 on 60 days" do
      @age_analysis.select{|item| item[:description] == "60 Days"}.first[:balance].to_s.should == "10300.0"
    end

    it "should have a balance of 7300.00 on 30 days" do
      @age_analysis.select{|item| item[:description] == "30 Days"}.first[:balance].to_s.should == "7300.0"
    end

    it "should have a balance of 12300.00 on present day" do
      @age_analysis.select{|item| item[:description] == "Present"}.first[:balance].to_s.should == "12300.0"
    end
  end
end