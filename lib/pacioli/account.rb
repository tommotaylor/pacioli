module Pacioli
  class Account < ActiveRecord::Base
    has_many :transactions, foreign_key: :pacioli_account_id

    def asset?
      false
    end

    def liability?
      false
    end

    def equity?
      false
    end

    def income?
      false
    end

    def expense?
      false
    end
  end
end