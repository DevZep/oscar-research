module AdvancedSearches
  class ClientBaseSqlBuilder
    ASSOCIATION_FIELDS = ['active_program_stream']
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
        field    = rule['id']
        operator = rule['operator']
        value    = rule['value']
        form_builder = field != nil ? field.split('_') : []
        if ASSOCIATION_FIELDS.include?(field)
          association_filter = AdvancedSearches::ClientAssociationFilter.new(@clients, field, operator, value).get_sql
          @sql_string << association_filter[:id]
          @values     << association_filter[:values]
        elsif form_builder.first == 'basicfield'
          sql_string = 'clients.id IN (?)'
          field = field.split('basicfield_').last
          if field == 'date_of_birth'
            values = age_field_query(operator, value)
            @sql_string << sql_string
            @values << values
          elsif field == 'current_province'
            values = current_province(operator, value)
            @sql_string << sql_string
            @values << values
          elsif field == 'district'
            values = district_query(operator, value)
            @sql_string << sql_string
            @values << values
          else
            base_sql(field, operator, value)
          end
        elsif form_builder.first == 'domainscore'
          domain_name = rule['id'].split('__').last
          domain_id = Domain.find_by(identity: domain_name).try(:id)
          domain_scores = AdvancedSearches::DomainScoreSqlBuilder.new(domain_id, rule).get_sql
          @sql_string << domain_scores[:id]
          @values << domain_scores[:values]
        elsif field != nil
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

    def age_field_query(operator, value)
      date_value_format = convert_age_to_date(value)
      case operator
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


    def current_province(operator, value)
      clients = @clients.joins(:province)
      province_id = Province.find_by(name: value).try(:id)
      case operator
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

    def district_query(operator, value)
      clients = @clients.joins(:district)
      district_id = District.find_by(name: value).try(:id)
      case operator
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
  end
end
