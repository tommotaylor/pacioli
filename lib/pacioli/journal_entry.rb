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

    def debit(options={})
      account = self.company.accounts.where(name: options[:account]).first
      self.transactions << Debit.new(journal_entry: self, account: account, amount: options[:amount])
    end

    def credit(options={})
      account = self.company.accounts.where(name: options[:account]).first
      self.transactions << Credit.new(journal_entry: self, account: account, amount: options[:amount])
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
  end
end