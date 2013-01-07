module Pacioli
  class AccountsNotBalancedException < Exception; end
  class PostingRuleNotBalancedException < Exception; end
  class PostingRuleNotWholeException < Exception; end
end