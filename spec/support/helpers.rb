module Helpers
  def tear_it_down
    Pacioli::Company.delete_all
    Pacioli::Account.delete_all
    Pacioli::JournalEntry.delete_all
    Pacioli::Transaction.delete_all
    Pacioli::PostingRule.destroy_all
    Pacioli::Party.destroy_all
  end
end                                                                                                                                   
        