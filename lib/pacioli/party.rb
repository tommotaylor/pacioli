module Pacioli
  class Party < ActiveRecord::Base
    belongs_to :partyable, polymorphic: true
    belongs_to :company, foreign_key: :pacioli_company_id
    has_many :transactions, foreign_key: :pacioli_party_id

    def self.for(party)
      Party.where(partyable_type: party.class.name, partyable_id: party.id) #.first || Customer.create!(customerable_type: customer.class.name, customerable_id: customer.id)
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
  end
end