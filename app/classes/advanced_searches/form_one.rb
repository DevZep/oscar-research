module AdvancedSearches
  class  FormOne
    include AdvancedSearchHelper

    def initialize(options = {})
      @user = options[:user]
    end

    def render
      AdvancedSearches::BasicFields.new(user: @user).render
    end
  end
end
