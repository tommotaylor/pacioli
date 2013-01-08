module Pacioli
  class JournalEntry < ActiveRecord::Base
    belongs_to :company, foreign_key: :pacioli_company_id
    has_many :transactions, foreign_key: :pacioli_journal_entry_id

    def with_description(desc)
      self.description = desc
    end

    def with_amount(amt)
      self.amount = amt
    end

    def type(type=nil)
      self.journal_type = type
    end

    def debit(options={})
      account = self.company.accounts.where(name: options[:account]).first
      debit = Debit.new(journal_entry: self, account: account, amount: options[:amount])
      debit.customer = options[:against_customer] if options.has_key? :against_customer
      self.transactions << debit
    end

    def credit(options={})
      account = self.company.accounts.where(name: options[:account]).first
      credit = Credit.new(journal_entry: self, account: account, amount: options[:amount])
      credit.customer = options[:against_customer] if options.has_key? :against_customer
      self.transactions << credit
    end

    def balanced?
      debits.sum(&:amount) == credits.sum(&:amount)
    end

    def debits
      transactions.where(type: 'Pacioli::Debit')
    end

    def credits
      transactions.where(type: 'Pacioli::Credit')
    end

    def calculate_amount
      credits.sum(&:amount)
    end

    def execute_posting_rules
      return if journal_type.blank?
      posting_rule = self.company.posting_rules.where(name: self.journal_type).first
      
      posting_rule.rules[:debits].each do |debit|
        self.debit(account: debit[:account], amount: (self.amount / 100) * debit[:percentage])
      end

      posting_rule.rules[:credits].each do |credit|
        self.credit(account: credit[:account], amount: (self.amount / 100) * credit[:percentage])
      end
    end
  end
end