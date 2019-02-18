module AdvancedSearches
  class ClientProblemsSqlBuilder

    def initialize(problem, rule)
      @operator     = rule['operator']
      @value        = rule['value']
      @problem    = problem
    end

    def get_sql
      client_problems  = @problem.client_problems
      sql_string = 'clients.id IN (?)'
      case @operator
      when 'equal'
        client_problems = client_problems.where(rank: @value)
      when 'not_equal'
        client_problems = client_problems.where.not(rank: @value)
      when 'less'
        client_problems = client_problems.where('client_problems.problem_id = ? and client_problems.rank < ?', @problem.id, @value)
      when 'less_or_equal'
        client_problems = client_problems.where('client_problems.problem_id = ? and client_problems.rank <= ?', @problem.id, @value)
      when 'greater'
        client_problems = client_problems.where('client_problems.problem_id = ? and client_problems.rank > ?', @problem.id, @value)
      when 'greater_or_equal'
        client_problems = client_problems.where('client_problems.problem_id = ? and client_problems.rank >= ?', @problem.id, @value)
      when 'between'
        client_problems = client_problems.where(problem_id: @problem.id, rank: @value.first..@value.last)
      when 'is_empty'
        client_problems = client_problems.where('client_problems.problem_id = ? and client_problems.rank IS NOT NULL', @problem.id)
        client_ids = Client.where.not(id: client_problems.pluck(:client_id).uniq).pluck(:id).uniq
      when 'is_not_empty'
        client_problems = client_problems.where('client_problems.problem_id = ? and client_problems.rank IS NOT NULL', @problem.id)
      end
      client_ids = client_problems.pluck(:client_id).uniq unless @operator == 'is_empty'
      { id: sql_string, values: client_ids }
    end
  end
end
