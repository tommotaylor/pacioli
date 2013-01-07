require 'spec_helper'

describe Pacioli::Account do 
  include Helpers

  before(:each) do
    tear_it_down

    @company = Pacioli::register_company do
      with_name "Coca-Cola"
      add_asset_account name: "Accounts Receivable", code: "100"
      add_income_account name: "Sales", code: "301"
      add_liability_account name: "Sales Tax", code: "401"
    end
  end

  context "Recording a journal entry" do
    before(:each) do
      @company.record_journal_entry do
        with_description "Invoice 123 for November Rent"
        debit account: "Accounts Receivable", amount: 4500.00
        credit account: "Sales", amount: 4500.00
      end
    end

    it "should record a journal entry" do
      Pacioli::JournalEntry.all.count.should == 1
    end

    it "should record 1 transaction against Accounts Receivable Account" do
      @company.accounts.where(name: "Accounts Receivable").first.transactions.count.should == 1
    end

    it "should have recorded 1 transaction against the Sales Account" do
      @company.accounts.where(name: "Sales").first.transactions.count.should == 1
    end

    it "should balance" do
      Pacioli::JournalEntry.last.should be_balanced
    end

    it "should record the amount of 4500.00 for the journal entry" do
      Pacioli::JournalEntry.last.amount.should == 4500.00 
    end
  end

  context "Recording a journal entry where the T-tables do not balance" do
    it "should raise an AccountsNotBalancedException error" do
      lambda {
        @company.record_journal_entry do
          with_description "Invoice 123 for November Rent"
          debit account: "Accounts Receivable", amount: 4500.00
        end
      }.should raise_error(Pacioli::AccountsNotBalancedException, "The aggregate balance of all accounts having positive balances must be equal to the aggregate balance of all accounts having negative balances.")
      
      Pacioli::JournalEntry.all.should be_blank
    end
  end

  context "Recording specific types of journal entries using posting rules" do
    context "Against 2 accounts" do
      before(:each) do
        @company.create_posting_rule do
          with_name :sale
          debit "Accounts Receivable"
          credit "Sales"
        end

        @sales = @company.record_journal_entry do
          with_amount 5000.00
          with_description "Invoice 123 for November Rent"
          type :sale
        end
      end

      it "should create a debit transaction against the Accounts Receivable account for 5000.00" do
        account = @company.accounts.where(name: "Accounts Receivable").first
        account.transactions.count.should == 1
      end

      it "should create a credit transaction against the Sales account for 5000.00" do
        account = @company.accounts.where(name: "Sales").first
        account.transactions.count.should == 1
      end

      it "should be balanced" do 
        @sales.should be_balanced
      end
    end

    context "Against multiple accounts" do
      before(:each) do
        @company.create_posting_rule do
          with_name :sale
          debit "Accounts Receivable"
          credit "Sales", percentage: 86
          credit "Sales Tax", percentage: 14
        end

        @sales = @company.record_journal_entry do
          with_amount 100.00
          with_description "Invoice 123 for November Rent"
          type :sale
        end
      end

      it "should create a credit transaction against Sales for 86.00 and Sales Taxes for 14.00" do
        @sales.credits.map(&:amount).should == [BigDecimal('86.00'), BigDecimal('14.00')]
      end

      it "should create a debit transaction against Accounts Receivable" do
        @sales.debits.map(&:amount).should == [BigDecimal('100.00')]
      end
    end

    context "Against multiple accounts and a percentage of an amount" do

    end

  end
  
end

# record_journal_entry do
    #   description: "Invoice Bob for November Rent"
    #   source_document: InvoiceInstance
    #   subsidiary_ledger: CustomerAccount
    #   posting_references do 
    #     debit(AccountReceivable, amount: amount)
    #     credit(SalesAccount, amount: amount)
    #   end
    # end