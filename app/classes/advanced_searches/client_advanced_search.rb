module AdvancedSearches
  class ClientAdvancedSearch
    def initialize(basic_rules, basic_sql)
      # @clients            = clients
      @basic_rules      = basic_rules
      @basic_sql        = basic_sql
    end

    def filter
      query_array         = []
      client_base_sql     = AdvancedSearches::ClientBaseSqlBuilder.new(@basic_rules, @basic_sql).generate
      # query_array << client_base_sql[:sql_string]
      # client_base_values  = client_base_sql[:values].map{ |v| query_array << v }
      # @clients.where(query_array)
      client_base_sql[:values]
    end
  end
end
