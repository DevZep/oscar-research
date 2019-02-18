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
      case @field
      when 'current_province'
        values = birth_province
      when 'district'
        values = district_query
      when 'age'
        values = age_field_query
      when 'active_program_stream'
        values = active_program_stream_query
      end
      { id: sql_string, values: values }
    end

    private

    def active_program_stream_query
      clients = @clients.select{|client| client.client_enrollments.active.count == @value.to_i}
      clients.map(&:id)
    end

    def birth_province
      clients = @clients.joins(:province)
      province_id = Province.find_by(name: @value).try(:id)
      case @operator
      when 'equal'
        clients = clients.where(province_id: province_id).ids if province_id.present?
      when 'not_equal'
        clients = clients.where.not(province_id: province_id).ids if province_id.present?
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def district_query
      clients = @clients.joins(:district)
      district_id = District.find_by(name: @value).try(:id)
      case @operator
      when 'equal'
        clients = clients.where(district_id: district_id).ids if district_id.present?
      when 'not_equal'
        clients = clients.where.not(district_id: district_id).ids if district_id.present?
      when 'is_empty'
        @clients.where.not(id: clients.ids).ids
      when 'is_not_empty'
        @clients.where(id: clients.ids).ids
      end
    end

    def age_field_query
      date_value_format = convert_age_to_date(@value)
      case @operator
      when 'equal'
        clients = @clients.where(date_of_birth: date_value_format.last_year.tomorrow..date_value_format)
      when 'not_equal'
        clients = @clients.where.not(date_of_birth: date_value_format.last_year.tomorrow..date_value_format)
      when 'less'
        clients = @clients.where('date_of_birth > ?', date_value_format)
      when 'less_or_equal'
        clients = @clients.where('date_of_birth >= ?', date_value_format.last_year)
      when 'greater'
        clients = @clients.where('date_of_birth < ?', date_value_format.last_year)
      when 'greater_or_equal'
        clients = @clients.where('date_of_birth <= ?', date_value_format)
      when 'between'
        clients = @clients.where(date_of_birth: date_value_format[0]..date_value_format[1])
      when 'is_empty'
        clients = @clients.where('date_of_birth IS NULL')
      when 'is_not_empty'
        clients = @clients.where.not('date_of_birth IS NULL')
      end
      clients.ids
    end

    def convert_age_to_date(value)
      overdue_year = 999.years.ago.to_date
      if value.is_a?(Array)
        min_age = (value[0].to_i * 12).months.ago.to_date
        max_age = ((value[1].to_i + 1) * 12).months.ago.to_date.tomorrow
        min_age = min_age > overdue_year ? min_age : overdue_year
        max_age = max_age > overdue_year ? max_age : overdue_year
        [max_age, min_age]
      else
        age = (value.to_i * 12).months.ago.to_date
        age > overdue_year ? age : overdue_year
      end
    end

    def validate_family_id(ids)
      if ids.is_a?(Array)
        first_value = ids.first.to_i > 1000000 ? "1000000" : ids.first
        last_value  = ids.last.to_i > 1000000 ? "1000000" : ids.last
        [first_value, last_value]
      else
        ids.to_i > 1000000 ? "1000000" : ids
      end
    end
  end
end
