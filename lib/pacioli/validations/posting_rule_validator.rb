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
    end
  end
end