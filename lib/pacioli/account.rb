module Pacioli
  class Account < ActiveRecord::Base
    has_many :transactions, foreign_key: :pacioli_account_id

    def asset?
      false
    end

    def liability?
      false
    end

    def equity?
      false
    end

    def income?
      false
    end

    def expense?
      false
    end

    def debits
      transactions.where(type: 'Pacioli::Debit')
    end

    def credits
      transactions.where(type: 'Pacioli::Credit')
    end

    def balanced?
      debits.sum(&:amount) == credits.sum(&:amount)
    end

    def balance
      debits.sum(&:amount) - credits.sum(&:amount)
    end

    def credited_with_source_document?(source)
      # has this account recorded a credit entry for the source document
      self.transactions.select(&:credit?).map(&:journal_entry).select {|je| je.source == source}.any?
    end

    def debited_with_source_document?(source)
      # has this account recorded a debit entry for the source document
      self.transactions.select(&:debit?).map(&:journal_entry).select {|je| je.source == source}.any?
    end

    def self.for(name)
      where(name: name)
    end 
  end
end