module Pacioli
  class Transaction < ActiveRecord::Base
    belongs_to :journal_entry, foreign_key: :pacioli_journal_entry_id
    belongs_to :account, foreign_key: :pacioli_account_id
    belongs_to :customer, foreign_key: :pacioli_customer_id

    def debit?
      false
    end

    def credit?
      false
    end
  end
end