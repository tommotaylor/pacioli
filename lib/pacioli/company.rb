module Pacioli
  class Company < ActiveRecord::Base
    belongs_to :companyable, polymorphic: true
    has_many :accounts, foreign_key: :pacioli_company_id, dependent: :destroy
    has_many :chart_of_accounts, through: :accounts
    has_many :journal_entries, foreign_key: :pacioli_company_id, dependent: :destroy
    has_many :posting_rules, foreign_key: :pacioli_company_id, dependent: :destroy
    has_many :parties, foreign_key: :pacioli_company_id, dependent: :destroy

    has_many :debtors, foreign_key: :pacioli_company_id, dependent: :destroy
    has_many :creditors, foreign_key: :pacioli_company_id, dependent: :destroy

    def self.for(company)
      Company.where(companyable_type: company.class.name, companyable_id: company.id).includes(:parties, accounts: [transactions: [:journal_entry]]).first 
    end

    def fetch_account(name)
      self.accounts.for(name).first
    end

    def asset_accounts
      self.accounts.select(&:asset?)
    end

    def liability_accounts
      self.accounts.select(&:liability?)
    end

    def expense_accounts
      self.accounts.select(&:expense?)
    end

    def income_accounts
      self.accounts.select(&:income?)
    end

    def equity_accounts
      self.accounts.select(&:equity?)
    end

    def asset_accounts
      self.accounts.select(&:asset?)
    end

    def with_name(company_name)
      self.name = company_name
    end

    def with_source(companyable_object)
      self.companyable = companyable_object
    end

    def add_account(account)
      self.accounts << account
      CompanyValidator.for(self).execute
      account
    end

    def add_asset_account(options={})
      add_account AssetAccount.new(options)
    end

    def add_equity_account(options={})
      add_account EquityAccount.new(options)
    end

    def add_liability_account(options={})
      add_account LiabilityAccount.new(options)
    end

    def add_income_account(options={})
      add_account IncomeAccount.new(options)
    end

    def add_expense_account(options={})
      add_account ExpenseAccount.new(options)
    end

    def record_journal_entry(&block)
      self.transaction do
        journal_entry = JournalEntry.new
        self.journal_entries << journal_entry
        journal_entry.instance_eval(&block)

        journal_entry.execute_posting_rules

        JournalEntryValidator.for(journal_entry).execute

        journal_entry.amount = journal_entry.calculate_amount if journal_entry.amount.blank?
        journal_entry.save!
        journal_entry
      end
    end

    def create_posting_rule(&block)
      self.transaction do
        posting_rule = PostingRule.new
        self.posting_rules << posting_rule
        posting_rule.instance_eval(&block)

        PostingRuleValidator.for(posting_rule).execute

        posting_rule.save!
        posting_rule
      end
    end

    def register_debtor(&block)
      self.transaction do 
        debtor = Debtor.new
        self.parties << debtor
        debtor.instance_eval(&block)
        debtor.save!
        debtor
      end
    end

    def register_creditor(&block)
      self.transaction do 
        creditor = Creditor.new
        self.parties << creditor
        creditor.instance_eval(&block)
        creditor.save!
        creditor
      end
    end
  end
end