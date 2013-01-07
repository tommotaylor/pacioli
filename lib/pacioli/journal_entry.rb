module Pacioli
  class JournalEntry < ActiveRecord::Base
    belongs_to :company, foreign_key: :pacioli_company_id
    has_many :transactions

    def with_description(desc)
      self.description = desc
    end

    def debit(options={})
      account = self.company.accounts.where(name: options[:account]).first
      self.transactions << Debit.new(journal_entry: self, account: account, amount: options[:amount])
    end

    def credit(options={})
      account = self.company.accounts.where(name: options[:account]).first
      self.transactions << Credit.new(journal_entry: self, account: account, amount: options[:amount])
    end

    def balance?
      # check that the transactions balance
    end
  end
end