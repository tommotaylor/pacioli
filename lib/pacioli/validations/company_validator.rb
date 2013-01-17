module Pacioli
  class CompanyValidator
    attr_accessor :company

    def self.for(company)
      validator = new
      validator.company = company
      validator
    end

    def execute
      validate_accounts
    end

    def validate_accounts
      accounts = self.company.accounts.map(&:name)
      raise Pacioli::CompanyAccountException, "The company has multiple accounts with the same name: '#{accounts.detect{ |e| accounts.count(e) > 1 }}' already exists" unless accounts.detect{ |e| accounts.count(e) > 1 }.nil?
    end
  end
end