module Pacioli
  class JournalEntryValidator
    attr_accessor :journal_entry

    def self.for(journal_entry)
      validator = new
      validator.journal_entry = journal_entry
      validator
    end

    def execute
      unless self.journal_entry.balanced?
        raise Pacioli::AccountsNotBalancedException, "The aggregate balance of all accounts having positive balances must be equal to the aggregate balance of all accounts having negative balances."
      end
    end
  end
end