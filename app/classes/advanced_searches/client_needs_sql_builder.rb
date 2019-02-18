module AdvancedSearches
  class ClientNeedsSqlBuilder

    def initialize(need, rule)
      @operator     = rule['operator']
      @value        = rule['value']
      @need    = need
    end

    def get_sql
      client_needs  = @need.client_needs
      sql_string = 'clients.id IN (?)'

      case @operator
      when 'equal'
        client_needs = client_needs.where(rank: @value)
      when 'not_equal'
        client_needs = client_needs.where.not(rank: @value)
      when 'less'
        client_needs = client_needs.where('client_needs.need_id = ? and client_needs.rank < ?', @need.id, @value)
      when 'less_or_equal'
        client_needs = client_needs.where('client_needs.need_id = ? and client_needs.rank <= ?', @need.id, @value)
      when 'greater'
        client_needs = client_needs.where('client_needs.need_id = ? and client_needs.rank > ?', @need.id, @value)
      when 'greater_or_equal'
        client_needs = client_needs.where('client_needs.need_id = ? and client_needs.rank >= ?', @need.id, @value)
      when 'between'
        client_needs = client_needs.where(need_id: @need.id, rank: @value.first..@value.last)
      when 'is_empty'
        client_needs = client_needs.where('client_needs.need_id = ? and client_needs.rank IS NOT NULL', @need.id)
        client_ids = Client.where.not(id: client_needs.pluck(:client_id).uniq).pluck(:id).uniq
      when 'is_not_empty'
        client_needs = client_needs.where('client_needs.need_id = ? and client_needs.rank IS NOT NULL', @need.id)
      end
      client_ids = client_needs.pluck(:client_id).uniq unless @operator == 'is_empty'
      { id: sql_string, values: client_ids }
    end
  end
end
