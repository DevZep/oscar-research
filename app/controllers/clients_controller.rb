class ClientsController < AdminController
  before_action :find_params_advanced_search, :client_builder_fields, :build_advanced_search, only: :index
  before_action :basic_params, if: :has_params?

  def index
    respond_to do |f|
      clients = list_clients_filter
      f.html do
        @clients = clients
        # @clients = Kaminari.paginate_array(clients).page(params[:page]).per(20)
      end
    end
  end

  private

  def clients_ordered(clients)
    clients = clients
    column = params[:order]
    return clients unless column
    if %w(age_as_years id_poor).include?(column)
      ordered = clients.sort_by{ |p| p.send(column).to_i }
    elsif column == 'slug'
      ordered = clients.sort_by{ |p| [p.send(column).split('-').first, p.send(column)[/\d+/].to_i] }
    else
      ordered = clients.sort_by{ |p| p.send(column).to_s.downcase }
    end
    column.present? && params[:descending] == 'true' ? ordered.reverse : ordered
  end

  def fetch_clients
    # org_short_names = Organization.pluck(:short_name)
    all_clients = []
    org_short_names = Organization.cambodian.visible.where(short_name: ['cif', 'mtp']).pluck(:short_name)
    sql = org_short_names.map do |ngo|
        "
          SELECT '#{ngo}' organization_name, #{ngo}.clients.id, #{ngo}.clients.slug, #{ngo}.clients.initial_referral_date,
          #{ngo}.clients.date_of_birth, #{ngo}.clients.gender, EXTRACT(year FROM age(current_date, date_of_birth)) display_age,
          #{ngo}.clients.status, #{ngo}.clients.birth_province_id, bp.name birth_province_name, cp.name province_name,
          d.name district_name, #{ngo}.clients.province_id, #{ngo}.clients.district_id,
          (SELECT COUNT(*) FROM #{ngo}.client_enrollments WHERE #{ngo}.client_enrollments.client_id = #{ngo}.clients.id) enrollment_count,
          rs.name referral_source_category_name, cr.client_relationship FROM #{ngo}.clients
          LEFT OUTER JOIN #{ngo}.provinces cp ON cp.id = #{ngo}.clients.province_id
          LEFT OUTER JOIN #{ngo}.districts d ON d.id = #{ngo}.clients.district_id
          LEFT OUTER JOIN #{ngo}.carers cr ON cr.id = #{ngo}.clients.carer_id
          LEFT OUTER JOIN #{ngo}.referral_sources rs ON rs.id = #{ngo}.clients.referral_source_category_id
          LEFT OUTER JOIN #{ngo}.provinces bp ON bp.id = #{ngo}.clients.birth_province_id
        ".squish
      end.join(" UNION ")

    fetched_clients = ActiveRecord::Base.connection.execute(sql).to_a.group_by{|record| record['organization_name'] }
    org_short_names.map do |short_name|
      Organization.switch_to(short_name)
      clients = fetched_clients[short_name]
      all_clients << map_clients(clients, short_name)
    end

    Organization.switch_to('public')
    all_clients.flatten(1).uniq
  end

  def decorate_clients(value)
    ClientDecorator.decorate(value)
  end

  def client_filter_adavnced_searches
    return unless has_params?
    basic_rules     = JSON.parse @basic_filter_params
    basicfield_ngo  = []
    org_short_names = Organization.cambodian.visible.pluck(:short_name)
    # org_short_names = Organization.pluck(:short_name)
    filter_client_advanced_serach(org_short_names, basic_rules)
  end

  def build_advanced_search
    @advanced_search = AdvancedSearch.new
  end

  def client_builder_fields
    @builder_fields = get_client_basic_fields
  end

  def get_client_basic_fields
    AdvancedSearches::FormOne.new(user: current_user).render
  end

  def has_params?
    @advanced_search_params.present? && @advanced_search_params[:basic_rules].present?
  end

  def find_params_advanced_search
    @advanced_search_params = params[:client_advanced_search]
  end

  def basic_params
    @basic_filter_params  = @advanced_search_params[:basic_rules]
  end

  def basic_sql
    @basic_sql_params  = JSON.parse(@advanced_search_params[:basic_sql]).presence || { sql: '', params: {} }
  end

  def list_clients_filter
    if has_params?
      clients = clients_ordered(client_filter_adavnced_searches)
    else
      clients = fetch_clients
    end
  end

  def filter_client_advanced_serach(ngos, basic_rules)
    all_clients = []
    filered_clients = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, basic_sql).filter
    ngos.map do |short_name|
      Organization.switch_to(short_name)
      clients = filered_clients[short_name]
      next if clients.blank?
      all_clients << map_clients(clients, short_name)
    end
    Organization.switch_to('public')
    all_clients.flatten(1).compact.uniq
  end

  def map_clients(clients, short_name)
    return [] if clients.blank?
    scores = []
    csi_domains = Domain.csi_domains.order_by_name
    default_assessments = Assessment.joins(:client).defaults
    scores_hash = default_assessments.map {|assessment| ["#{assessment.client_id}", assessment, assessment.basic_info] }.group_by(&:first)
    clients_array = clients.map do |client|
      client = OpenStruct.new(client)
      # active_enrollments   = client.client_enrollments.active
      active_enrollments   = ClientEnrollment.where(client_id: client.id).active
      # inactive_enrollments   = client.client_enrollments.inactive
      inactive_enrollments   = ClientEnrollment.where(client_id: client.id).active
      enrollment_count   = active_enrollments.count

      assessments   = scores_hash[client.id] || []
      assessment = assessments.map(&:second).flatten.max_by(&:created_at)
      if assessment.present?
        assessment_domains = assessment.assessment_domains.pluck(:domain_id, :score).to_h
        domain_scores = csi_domains.map{ |domain| assessment_domains[domain.id] || '' } if assessment_domains.present?
      else
        domain_scores = (1..12).map{ |_| '' }
      end

      active_enrollment_services = active_enrollments.joins(program_stream: :services).select("services.name")
      inactive_enrollment_services = inactive_enrollments.joins(program_stream: :services).select("services.name")
      data = {
        client: client,
        scores: assessments.present? ? assessments.map(&:last).flatten : [],
        assessment_count: assessments.flatten.count,
        enrollment_count: enrollment_count,
        domain_scores: [*domain_scores, ''][0..11],
        short_name: short_name,
        **map_exit_ngo(client),
        # carer_relationship_to_client: client.carer&.client_relationship,
        current_services: active_enrollment_services.map(&:name).uniq.join(", "),
        past_services: inactive_enrollment_services.map(&:name).uniq.join(", "),
        assessment_date: assessment&.created_at&.strftime('%d %B %Y'),
        # referral_source_category: decorate_clients(client)&.referral_source_category,
        reason_for_family_separation: map_quantitative_type_by_name(client, 'Reason for Family Separation'),
        history_of_harm: map_quantitative_type_by_name(client, 'History of Harm'),
        history_of_disability_and_or_illness: map_quantitative_type_by_name(client, 'History of Disability'),
        history_of_high_risk_behaviours: map_quantitative_type_by_name(client, 'History of high-risk behaviours')
      }
      data
    end
  end

  def map_quantitative_type_by_name(client, value)
    QuantitativeCase.joins(:client_quantitative_cases).where(client_quantitative_cases: { client_id: client.id }).joins(:quantitative_type).merge(QuantitativeType.name_like(value)).pluck(:value).join(", ")
  end

  def map_exit_ngo(client)
    exit_ngo = ExitNgo.where(client_id: client.id).last
    {
      exit_circumstance: exit_ngo&.exit_circumstance,
      exit_reasons: exit_ngo&.exit_reasons&.join(", "),
    }
  end

  def map_non_assessment_clients(clients, short_name)
    clients_array = clients.map do |client|
      { client: client, scores: [], assessment_count: 0, enrollment_count: 0, domain_scores: (1..12).map{ |_| '' }, short_name: short_name }
    end
  end
end
