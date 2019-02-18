module AdvancedSearches
  class ClientBaseSqlBuilder
    ASSOCIATION_FIELDS = ['age', 'current_province', 'district', 'active_program_stream']
    BLANK_FIELDS = ['date_of_birth']
    # SENSITIVITY_FIELDS = %w(kid_id street_number house_number gov_city gov_district gov_commune gov_village_code gov_client_code gov_interview_village gov_interview_commune gov_interview_district gov_interview_city gov_caseworker_name gov_caseworker_phone gov_carer_name gov_carer_relationship gov_carer_home gov_carer_street gov_carer_village gov_carer_commune gov_carer_district gov_carer_city gov_carer_phone)

    def initialize(clients, rules)
      @clients     = clients
      @values      = []
      @sql_string  = []
      @condition    = rules['condition']
      @basic_rules  = rules['rules'] || []

      @columns_visibility = []
    end

    def generate
      @basic_rules.each do |rule|
        field    = rule['field']
        operator = rule['operator']
        value    = rule['value']
        form_builder = field != nil ? field.split('_') : []
        if ASSOCIATION_FIELDS.include?(field)
          association_filter = AdvancedSearches::ClientAssociationFilter.new(@clients, field, operator, value).get_sql
          @sql_string << association_filter[:id]
          @values     << association_filter[:values]
        elsif form_builder.first == 'basicfield'
          field = field.split('basicfield_').last
          value = field == 'grade' ? validate_integer(value) : value
          base_sql(field, operator, value)
        elsif field != nil
          value = field == 'grade' ? validate_integer(value) : value
          base_sql(field, operator, value)
        else
          nested_query =  AdvancedSearches::ClientBaseSqlBuilder.new(@clients, rule).generate
          @sql_string << nested_query[:sql_string]
          nested_query[:values].select{ |v| @values << v }
        end
      end

      @sql_string = @sql_string.join(" #{@condition} ")
      @sql_string = "(#{@sql_string})" if @sql_string.present?
      { sql_string: @sql_string, values: @values }
    end

    private

    def base_sql(field, operator, value)
      case operator
      when 'equal'
        @sql_string << "clients.#{field} = ?"
        @values << value

      when 'not_equal'
        @sql_string << "clients.#{field} != ?"
        @values << value

      when 'less'
        @sql_string << "clients.#{field} < ?"
        @values << value

      when 'less_or_equal'
        @sql_string << "clients.#{field} <= ?"
        @values << value

      when 'greater'
        @sql_string << "clients.#{field} > ?"
        @values << value

      when 'greater_or_equal'
        @sql_string << "clients.#{field} >= ?"
        @values << value

      when 'contains'
        @sql_string << "clients.#{field} ILIKE ?"
        @values << "%#{value}%"

      when 'not_contains'
        @sql_string << "clients.#{field} NOT ILIKE ?"
        @values << "%#{value}%"

      when 'is_empty'
        if BLANK_FIELDS.include? field
          @sql_string << "clients.#{field} IS NULL"
        else
          @sql_string << "(clients.#{field} IS NULL OR clients.#{field} = '')"
        end

      when 'is_not_empty'
        if BLANK_FIELDS.include? field
          @sql_string << "clients.#{field} IS NOT NULL"
        else
          @sql_string << "(clients.#{field} IS NOT NULL AND clients.#{field} != '')"
        end

      when 'between'
        @sql_string << "clients.#{field} BETWEEN ? AND ?"
        @values << value.first
        @values << value.last
      end
    end

    def validate_integer(values)
      if values.is_a?(Array)
        first_value = values.first.to_i > 1000000 ? "1000000" : values.first
        last_value  = values.last.to_i > 1000000 ? "1000000" : values.last
        [first_value, last_value]
      else
        values.to_i > 1000000 ? "1000000" : values
      end
    end
  end
end
