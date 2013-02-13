module Pacioli
  class Debtor < Party

    def self.for(debtor)
      Debtor.where(partyable_type: debtor.class.name, partyable_id: debtor.id).first || Debtor.create!(partyable_type: debtor.class.name, partyable_id: debtor.id)
    end

  end
end