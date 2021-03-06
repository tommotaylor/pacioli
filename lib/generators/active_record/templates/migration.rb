class CreatePacioliTables < ActiveRecord::Migration
  def self.change

    create_table :pacioli_companies, :force => true do |t|
      t.integer :companyable_id
      t.string :companyable_type
      t.string :name

      t.timestamps
    end

    create_table :pacioli_parties, :force => true do |t|
      t.references :pacioli_company
      t.integer :partyable_id
      t.string :partyable_type
      t.string :type
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
      t.string :journal_type
      t.string :description
      t.references :pacioli_company
      t.decimal :amount, :precision => 20, :scale => 10

      t.integer :source_documentable_id
      t.string :source_documentable_type

      t.datetime :dated, default: Time.now
      t.timestamps
    end

    create_table :pacioli_transactions, :force => true do |t|
      t.references :pacioli_journal_entry
      t.references :pacioli_account
      t.references :pacioli_party

      t.string :type
      t.decimal :amount, :precision => 20, :scale => 10

      t.datetime :dated, default: Time.now
      t.timestamps
    end

    create_table :pacioli_posting_rules, :force => true do |t|
      t.references :pacioli_company
      t.string :name
      t.text :rules
    end

  end
end