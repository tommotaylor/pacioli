module Pacioli
  class JournalEntry < ActiveRecord::Base
    belongs_to :company

    def with_description(desc)
      self.description = desc
    end

    def debit(account)
      # debit
    end

    def credit(account)
      # credit
    end
  end
end