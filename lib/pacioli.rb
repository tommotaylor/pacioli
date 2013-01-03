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