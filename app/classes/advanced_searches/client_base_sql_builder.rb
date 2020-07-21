module AdvancedSearches
  class ClientBaseSqlBuilder
    ASSOCIATION_FIELDS = ['active_program_stream']
    BLANK_FIELDS = ['date_of_birth']
    # SENSITIVITY_FIELDS = %w(kid_id street_number house_number gov_city gov_district gov_commune gov_village_code gov_client_code gov_interview_village gov_interview_commune gov_interview_district gov_interview_city gov_caseworker_name gov_caseworker_phone gov_carer_name gov_carer_relationship gov_carer_home gov_carer_street gov_carer_village gov_carer_commune gov_carer_district gov_carer_city gov_carer_phone)

    def initialize(rules, basic_sql)
      # @clients     = clients
      @values      = []
      @sql_string  = []
      @condition    = rules['condition']
      @basic_rules  = rules['rules'] || []
      @basic_sql    = basic_sql

      @columns_visibility = []
    end

    def generate
      sql_string  = Client.sql_string_mapping(@basic_sql['sql'])
      sql = Organization.cambodian.visible.where.not(short_name: 'shared').pluck(:short_name).map do |ngo|
        "
          SELECT '#{ngo}' organization_name, #{ngo}.clients.id, #{ngo}.clients.slug, #{ngo}.clients.initial_referral_date,
          #{ngo}.clients.date_of_birth, #{ngo}.clients.gender, EXTRACT(year FROM age(current_date, date_of_birth)) age_display,
          #{ngo}.clients.status, #{ngo}.clients.birth_province_id, bp.name birth_province_name, cp.name province_name,
          d.name district_name, #{ngo}.clients.province_id, #{ngo}.clients.district_id,
          (SELECT COUNT(*) FROM #{ngo}.client_enrollments WHERE #{ngo}.client_enrollments.client_id = #{ngo}.clients.id) AS enrollment_count,
          rs.name referral_source_category_name, cr.client_relationship FROM #{ngo}.clients
          LEFT OUTER JOIN #{ngo}.provinces cp ON cp.id = #{ngo}.clients.province_id
          LEFT OUTER JOIN #{ngo}.districts d ON d.id = #{ngo}.clients.district_id
          LEFT OUTER JOIN #{ngo}.carers cr ON cr.id = #{ngo}.clients.carer_id
          LEFT OUTER JOIN #{ngo}.referral_sources rs ON rs.id = #{ngo}.clients.referral_source_category_id
          LEFT OUTER JOIN #{ngo}.provinces bp ON bp.id = #{ngo}.clients.birth_province_id
          #{sql_string.present? && "WHERE #{sql_string}".gsub('%{ngo}', ngo) }
        "
      end.join(" UNION ").squish

      results = ActiveRecord::Base.connection.execute(sql).to_a.group_by{|record| record['organization_name'] }
      @sql_string = @sql_string.join(" #{@condition} ")
      @sql_string = "(#{@sql_string})" if @sql_string.present?
      { sql_string: @sql_string, values: results }
    end
  end
end
