module Pacioli
  class Company < ActiveRecord::Base
    belongs_to :companyable, polymorphic: true
    has_many :accounts, foreign_key: :pacioli_company_id, dependent: :destroy
    has_many :chart_of_accounts, through: :accounts

    def self.for(company)
      Company.where(companyable_type: company.class.name, companyable_id: company.id).first || Company.create!(companyable_type: company.class.name, companyable_id: company.id)
    end

    def with_name(company_name)
      self.name = company_name
    end

    def with_source(companyable_object)
      self.companyable = companyable_object
    end

    def add_asset_account(options={})
      account = AssetAccount.create!(options)
      self.accounts << account
      account
    end

    def add_equity_account(options={})
      account = EquityAccount.create!(options)
      self.accounts << account
      account
    end

    def add_liability_account(options={})
      account = LiabilityAccount.create!(options)
      self.accounts << account
      account
    end

    def add_income_account(options={})
      account = IncomeAccount.create!(options)
      self.accounts << account
      account
    end

    def add_expense_account(options={})
      account = ExpenseAccount.create!(options)
      self.accounts << account
      account
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
  end
end