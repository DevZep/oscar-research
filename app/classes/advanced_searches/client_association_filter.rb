module AdvancedSearches
  class ClientAssociationFilter
    def initialize(clients, field, operator, values)
      @clients  = clients
      @field    = field
      @operator = operator
      @value   = values
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      values = active_program_stream_query
      { id: sql_string, values: values }
    end

    private

    def active_program_stream_query
      clients = @clients.select{|client| client.client_enrollments.active.count == @value.to_i}
      clients.map(&:id)
    end
  end
end
