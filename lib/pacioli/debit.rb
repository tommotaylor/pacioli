module Pacioli
  class Debit < Transaction

    def debit?
      true
    end

    def to_hash
      {description: self.journal_entry.description, date: self.dated, credit_amount: "", debit_amount: self.amount, balance: self.party.balance_at(self.dated)}
    end

  end
end