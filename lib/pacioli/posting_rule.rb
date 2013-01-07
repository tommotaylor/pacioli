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
      self.rules[:debits] << options
    end

    def credit(account_name, options={})

    end

    def prepare_rules(options={})
      options[:percentage] = 100 if options.empty?
    end

  end
end