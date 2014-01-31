module Pacioli
  class Party < ActiveRecord::Base
    belongs_to :partyable, polymorphic: true
    belongs_to :company, foreign_key: :pacioli_company_id
    has_many :transactions, foreign_key: :pacioli_party_id

    def self.for(party)
      Party.where(partyable_type: party.class.name, partyable_id: party.id).first || Party.create!(partyable_type: party.class.name, partyable_id: party.id, type: "Pacioli::Debtor") # By default creates a debtor
    end

    def with_name(party_name)
      self.name = party_name
    end

    def with_source(partyable_object)
      self.partyable = partyable_object
    end

    def debits
      transactions.where(type: 'Pacioli::Debit')
    end

    def credits
      transactions.where(type: 'Pacioli::Credit')
    end

    def balance
      debits.sum(&:amount) - credits.sum(&:amount)
    end

    def balance_at(date=Time.now, t_id=nil)
      if t_id.nil?
        debits.before(date).sum(&:amount) - credits.before(date).sum(&:amount)
      else
        debits.before(date).sum(&:amount) - credits.before(date).sum(&:amount)
      end
    end

    def statement_between_dates(start_date, end_date=Time.now)
      start_date ||= (Date.today - 1.month).to_time

      temp_array = []

      temp_array << {description: "Opening Balance", date: start_date, credit_amount: "", debit_amount: "", balance: balance_at(start_date)}

      #temp_array << transactions.between(start_date, end_date).map(&:to_hash)
      running_balance = balance_at(start_date)

      temp_array << transactions.between(start_date, end_date).map do |transaction|
        if (!transaction.journal_entry.source_documentable.blank?) && (transaction.journal_entry.source_documentable.respond_to?(:to_s))
          sdd = transaction.journal_entry.source_documentable.to_s
        else
          sdd = transaction.journal_entry.description
        end

        if transaction.credit?
          running_balance -= transaction.amount
          {description: transaction.journal_entry.description, date: transaction.dated, credit_amount: transaction.amount, debit_amount: "", balance: running_balance, source_document_description: sdd}
        else
          running_balance += transaction.amount
          {description: transaction.journal_entry.description, date: transaction.dated, debit_amount: transaction.amount, credit_amount: "", balance: running_balance, source_document_description: sdd}
        end
      end

      temp_array << {description: "Closing Balance", date: end_date, credit_amount: "", debit_amount: "", balance: balance_at(end_date)}

      temp_array.flatten
    end

    def age_analysis_report
      [
        {description: "Present", date: Date.today, balance: balance_at(Date.today), start_date: (Date.today - 30.days).strftime, end_date: Date.today.strftime},
        {description: "30 Days", date: Date.today - 30.days, balance: balance_at(Date.today - 30.days), start_date: (Date.today - 60.days).strftime, end_date:(Date.today - 30.days).strftime},
        {description: "60 Days", date: Date.today - 60.days, balance: balance_at(Date.today - 60.days), start_date: (Date.today - 90.days).strftime, end_date: (Date.today - 60.days).strftime},
        {description: "90 Days", date: Date.today - 90.days, balance: balance_at(Date.today - 90.days), start_date: (Date.today - 120.days).strftime, end_date: (Date.today - 90.days).strftime},
        {description: "120 Days", date: Date.today - 120.days, balance: balance_at(Date.today - 120.days), start_date: (Date.today - 150.days).strftime, end_date: (Date.today - 120.days).strftime}
      ]
    end

  end
end