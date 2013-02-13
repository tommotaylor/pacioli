module Pacioli
  class Creditor < Party

    def self.for(creditor)
      Creditor.where(partyable_type: creditor.class.name, partyable_id: creditor.id).first || Creditor.create!(partyable_type: creditor.class.name, partyable_id: creditor.id)
    end

  end
end