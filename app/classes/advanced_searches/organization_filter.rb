module AdvancedSearches
  class OrganizationFilter
    def initialize(operator, values)
      @operator = operator
      @value   = values
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      case @operator
      when 'equal'
        values = @value == Organization.current.short_name ? Client.pluck(:id) : []
      when 'not_equal'
        values = @value == Organization.current.short_name ? [] : Client.pluck(:id)
      end
      { id: sql_string, values: values }
    end
  end
end
