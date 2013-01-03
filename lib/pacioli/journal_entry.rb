module Pacioli
  class JournalEntry < ActiveRecord::Base
    belongs_to :company
    belongs_to :account
  end
end