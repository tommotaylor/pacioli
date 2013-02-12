module Pacioli
  class Credit < Transaction

    def credit?
      true
    end

    def to_hash
      {description: self.journal_entry.description, date: self.dated, credit_amount: self.amount, debit_amount: "", balance: self.party.balance_at(self.dated)}
    end

  end
end