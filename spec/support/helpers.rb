module Helpers
  def tear_it_down
    Pacioli::Company.delete_all
  end
end                                                                                                                                   
        