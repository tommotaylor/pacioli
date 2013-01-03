module Pacioli
  class Account < ActiveRecord::Base
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