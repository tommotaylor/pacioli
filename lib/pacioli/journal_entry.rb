module Pacioli
  class JournalEntry < ActiveRecord::Base
    belongs_to :company, foreign_key: :pacioli_company_id
    has_many :transactions, foreign_key: :pacioli_journal_entry_id
    belongs_to :source_documentable, polymorphic: true

    def with_description(desc)
      self.description = desc
    end

    def with_amount(amt)
      self.amount = amt
    end

    def with_source_document(source_document)
      self.source_documentable = source_document
    end

    def with_date(time=Time.now)
      self.dated = time
    end

    def type(type=nil)
      self.journal_type = type
    end

    def debit(options={})
      account = self.company.accounts.where(name: options[:account]).first
      debit = Debit.new(journal_entry: self, account: account, amount: options[:amount], dated: self.dated)
      debit.party = options[:against_party] if options.has_key? :against_party
      self.transactions << debit
    end

    def credit(options={})
      account = self.company.accounts.where(name: options[:account]).first
      credit = Credit.new(journal_entry: self, account: account, amount: options[:amount], dated: self.dated)
      credit.party = options[:against_party] if options.has_key? :against_party
      self.transactions << credit
    end

    def balanced?
      debits.sum(&:amount) == credits.sum(&:amount)
    end

    def debits
      transactions.where(type: 'Pacioli::Debit')
    end

    def credits
      transactions.where(type: 'Pacioli::Credit')
    end

    def calculate_amount
      credits.sum(&:amount)
    end

    def execute_posting_rules
      return if journal_type.blank?
      posting_rule = self.company.posting_rules.where(name: self.journal_type).first
      
      posting_rule.rules[:debits].each do |debit|
        self.debit(account: debit[:account], amount: (self.amount / 100) * debit[:percentage])
      end

      posting_rule.rules[:credits].each do |credit|
        self.credit(account: credit[:account], amount: (self.amount / 100) * credit[:percentage])
      end
    end

    def source
      source_documentable
    end

    # record
    # Could be used to update a journal entry and affect other accounts
    # eg. a payment into our bank would result in a journal entry but 
    # we may not know where it came from. At a later stage we could allocate
    # the payment to a debtor/invoice etc.

    def record(&block)
      self.transaction do
        self.instance_eval(&block)

        self.execute_posting_rules

        JournalEntryValidator.for(self).execute

        self.save!
        self
      end
    end

    def self.for(source)
      where(source_documentable_type: source.class.name, source_documentable_id: source.id).includes(transactions: [:account])
    end

    def pretty
      strings = ["".center(101, "-")]
      strings << "| Description".ljust(30, " ") + "| #{description}".ljust(70, " ") + "|"
      strings << "| Amount".ljust(30, " ") + "| #{amount}".ljust(70, " ") + "|"
      strings << "| Dated".ljust(30, " ") + "| #{dated}".ljust(70, " ") + "|"
      strings << "| Source Document".ljust(30, " ") + "| #{source_documentable_type} with id: #{source_documentable_id}".ljust(70, " ") + "|"
      strings << "".center(101, "-")
      strings << ""

      transactions.map do |transaction|
        strings << "(#{transaction.account.code}) #{transaction.account.name}".center(101, "-")
        if transaction.party.nil?
          party_name = ""
        else
          party_name = "(#{transaction.party.partyable_type}: #{transaction.party.name})"
        end

        if transaction.debit?
          item = ( "#{party_name} " + transaction.amount.to_s + " |").rjust(51, " ")
        else
          item = ("| ".rjust(52) + transaction.amount.to_s + " #{party_name}")
        end

        strings << item
        strings << ""
      end

      strings.join("\n")
    end
  end
end
