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
      #transactions.where(type: 'Pacioli::Debit')
      transactions.select(&:debit?)
    end

    def credits
      #transactions.where(type: 'Pacioli::Credit')
      transactions.select(&:credit?)
    end

    def debits_before(date)
      debits.select {|debit| debit.dated < date}
    end

    def credits_before(date)
      credits.select {|credit| credit.dated < date}
    end

    def balance
      debits.sum(&:amount) - credits.sum(&:amount)
    end

    def balance_at(date=Time.now, t_id=nil)
      if t_id.nil?
        debits_before(date.end_of_day).sum(&:amount) - credits_before(date.end_of_day).sum(&:amount)
      else
        debits_before(date.end_of_day).sum(&:amount) - credits_before(date.end_of_day).sum(&:amount)
      end
    end

    def statement_between_dates(start_date, end_date=Time.now)
      start_date ||= (Date.today - 1.month).to_time

      temp_array = []

      opening_balance = debits_before(start_date.beginning_of_day).sum(&:amount) - credits_before(start_date.beginning_of_day).sum(&:amount)

      temp_array << {description: "Opening Balance", date: start_date, credit_amount: "", debit_amount: "", balance: opening_balance}

      running_balance = opening_balance

      temp_array << transactions.between(start_date, end_date).map do |transaction|
        description = transaction.journal_entry.description

        if transaction.credit?
          running_balance -= transaction.amount
          {description: description, date: transaction.dated, credit_amount: transaction.amount, debit_amount: "", balance: running_balance, source_document_description: description}
        else
          running_balance += transaction.amount
          {description: description, date: transaction.dated, debit_amount: transaction.amount, credit_amount: "", balance: running_balance, source_document_description: description}
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