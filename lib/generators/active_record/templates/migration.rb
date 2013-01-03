class CreatePacioliTables < ActiveRecord::Migration
  def self.change

    create_table :pacioli_companies, :force => true do |t|
      t.integer :companyable_id
      t.string :companyable_type
      t.string :name

      t.timestamps
    end

    create_table :pacioli_accounts, :force => true do |t|
      t.references :pacioli_company
      t.string :code
      t.string :name
      t.string :description
      t.string :type

      t.timestamps
    end

    create_table :pacioli_journal_entries, :force => true do |t|
      t.string :type
      t.string :description
      t.string :posting_references
      t.references :pacioli_company
      t.references :pacioli_account
      t.decimal :amount, :precision => 20, :scale => 10
    end 

    add_index :plutus_amounts, :type
    add_index :plutus_amounts, [:account_id, :transaction_id]
    add_index :plutus_amounts, [:transaction_id, :account_id]

  end
end