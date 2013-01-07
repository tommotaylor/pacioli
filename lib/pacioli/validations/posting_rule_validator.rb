module Pacioli
  class PostingRuleValidator
    attr_accessor :posting_rule

    def self.for(posting_rule)
      validator = new
      validator.posting_rule = posting_rule
      validator
    end

    def execute
      raise Pacioli::PostingRuleNotBalancedException, "The aggregate balance of debits and credits must be equal" unless self.posting_rule.balanced?
      raise Pacioli::PostingRuleNotWholeException, "The aggregate balance of debits and credits must make up 100% of the amount." unless self.posting_rule.whole?
    end
  end
end