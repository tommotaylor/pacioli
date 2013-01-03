module Pacioli
  class Company < ActiveRecord::Base
    belongs_to :companyable, polymorphic: true

    def self.for(company)
      Company.where(companyable_type: company.class.name, companyable_id: company.id).first || Company.create!(companyable_type: company.class.name, companyable_id: company.id)
    end

    def with_name(company_name)
      self.name = company_name
    end

    def with_source(companyable_object)
      self.companyable = companyable_object
    end
  end
end