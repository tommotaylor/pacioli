module Pacioli
  class Party < ActiveRecord::Base
    belongs_to :partyable, polymorphic: true
    belongs_to :company, foreign_key: :pacioli_company_id
    has_many :transactions, foreign_key: :pacioli_party_id

    def self.for(party)
      Party.where(partyable_type: party.class.name, partyable_id: party.id).first #|| Customer.create!(customerable_type: customer.class.name, customerable_id: customer.id)
    end

    def with_name(party_name)
      self.name = party_name
    end

    def with_source(partyable_object)
      self.partyable = partyable_object
    end

    def debits
      transactions.where(type: 'Pacioli::Debit')
    end

    def credits
      transactions.where(type: 'Pacioli::Credit')
    end

    def balance
      debits.sum(&:amount) - credits.sum(&:amount)
    end

    def balance_at(date=Time.now)
      debits.before(date).sum(&:amount) - credits.before(date).sum(&:amount)
    end

    def statement_between_dates(start_date, end_date=Time.now)
      start_date ||= (Date.today - 1.month).to_time

      temp_array = []

      temp_array << {description: "Opening Balance", date: start_date, credit_amount: "", debit_amount: "", balance: balance_at(start_date)}

      temp_array << transactions.between(start_date, end_date).map(&:to_hash)

      temp_array << {description: "Closing Balance", date: end_date, credit_amount: "", debit_amount: "", balance: balance_at(end_date)}

      temp_array.flatten
    end
  end
end