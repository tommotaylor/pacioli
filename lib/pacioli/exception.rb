module Pacioli
  class AccountsNotBalancedException < Exception; end
  class PostingRuleNotBalancedException < Exception; end
  class CompanyAccountException < Exception; end
end