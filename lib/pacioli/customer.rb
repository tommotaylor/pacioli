module Pacioli
  class Customer < ActiveRecord::Base
    belongs_to :customerable, polymorphic: true
    belongs_to :company, foreign_key: :pacioli_company_id

    def self.for(customer)
      Customer.where(customerable_type: customer.class.name, customerable_id: customer.id).first || Customer.create!(customerable_type: customer.class.name, customerable_id: customer.id)
    end

    def with_name(customer_name)
      self.name = customer_name
    end

    def with_source(customerable_object)
      self.customerable = customerable_object
    end
  end
end