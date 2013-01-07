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