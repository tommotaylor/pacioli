ActiveRecord::Schema.define do

  create_table "pacioli_companies", :force => true do |t|
    t.integer "companyable_id"
    t.string "companyable_type"
    t.string "name"
    t.timestamps
  end

  create_table "pacioli_accounts", :force => true do |t|
    t.integer "pacioli_company_id"
    t.string "code"
    t.string "name"
    t.string "description"
    t.string "type"
    
    t.timestamps
  end
  
end
