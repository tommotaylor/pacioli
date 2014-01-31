module Pacioli
  class Transaction < ActiveRecord::Base
    belongs_to :journal_entry, foreign_key: :pacioli_journal_entry_id
    belongs_to :account, foreign_key: :pacioli_account_id
    belongs_to :party, foreign_key: :pacioli_party_id

    def self.before(date=Time.now)
      #where("dated < :q", q: date.to_time.end_of_day)
      where("dated < :q", q: date.to_time)
    end

    def self.between(start_date, end_date)
      where("dated >= :s AND dated <= :e", {s: start_date.to_time.beginning_of_day, e: end_date.to_time.end_of_day}).order(:dated)
    end

    def debit?
      false
    end

    def credit?
      false
    end
  end
end