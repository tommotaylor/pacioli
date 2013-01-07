module Pacioli
  class PostingRule < ActiveRecord::Base
    belongs_to :company, foreign_key: :pacioli_company_id

    serialize :rules

    def with_name(name)
      self.name = name
    end

    def debit(account_name, options={})
      self.rules ||= {}
      self.rules[:debits] ||= []
      self.rules[:debits] << prepare_rules(account_name, options)
    end

    def credit(account_name, options={})
      self.rules ||= {}
      self.rules[:credits] ||= []
      self.rules[:credits] << prepare_rules(account_name, options)
    end

    def prepare_rules(account_name, options={})
      options[:percentage] = 100 if options.empty?
      options[:account] = account_name
      options
    end

    def build(journal_entry)
      
    end

  end
end