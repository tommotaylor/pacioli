ActiveRecord::Schema.define do

  create_table "pacioli_companies", :force => true do |t|
    t.integer "companyable_id"
    t.string "companyable_type"
    t.string "name"
    t.timestamps
  end
  
end
