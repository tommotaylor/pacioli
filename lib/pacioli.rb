require "active_record"
require "pacioli/version"

module Pacioli
  def self.table_name_prefix
    'pacioli_'
  end

  def self.register_company(&block)
    company = Company.new
    company.instance_eval(&block)
    company.save!
    company
  end

end

require "pacioli/company"
require "pacioli/customer"
require "pacioli/account"
require "pacioli/asset_account"
require "pacioli/liability_account"
require "pacioli/equity_account"
require "pacioli/income_account"
require "pacioli/expense_account"
require "pacioli/journal_entry"
require "pacioli/transaction"
require "pacioli/credit"
require "pacioli/debit"
require "pacioli/posting_rule"
require "pacioli/exception"

require "pacioli/validations/journal_entry_validator"
require "pacioli/validations/posting_rule_validator"
require "pacioli/validations/company_validator"
