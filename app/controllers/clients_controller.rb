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
    org_short_names = Organization.cambodian.visible.pluck(:short_name)
    all_clients = []
    org_short_names.each do |short_name|
      Organization.switch_to(short_name)
      next unless (Setting.first && Setting.first.sharing_data?)
      clients = Client.joins(:assessments).select(:id, :date_of_birth, :status, :gender, :province_id, :district_id).reload
      all_clients << map_clients(clients.includes(:province, :district, :client_enrollments), short_name)
      clients = Client.where.not(id: clients.ids).select(:id, :date_of_birth, :status, :gender, :province_id, :district_id)
      all_clients << map_non_assessment_clients(clients.includes(:province, :district), short_name)
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

  def list_clients_filter
    if has_params?
      clients = clients_ordered(client_filter_adavnced_searches)
    else
      clients = fetch_clients
    end
  end

  def filter_client_advanced_serach(ngos, basic_rules)
    clients = ngos.map do |short_name|
      Organization.switch_to(short_name)
      next unless (Setting.first && Setting.first.sharing_data?)
      all_clients = []

      clients = Client.joins(:assessments).select(:id, :date_of_birth, :status, :gender, :province_id, :district_id).reload
      filered_clients = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, clients).filter
      all_clients << map_clients(filered_clients.includes(:province, :district, :client_enrollments), short_name)

      clients = Client.where.not(id: clients.ids).select(:id, :date_of_birth, :status, :gender, :province_id, :district_id)
      filered_clients = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, clients).filter
      all_clients << map_non_assessment_clients(filered_clients.includes(:province, :district), short_name) if filered_clients.present?

      all_clients.flatten.compact
    end
    Organization.switch_to('public')
    clients.flatten(1).compact.uniq
  end

  def map_clients(clients, short_name)
    return [] if clients.blank?
    scores = []
    csi_domains = Domain.csi_domains.order_by_name
    default_assessments = Assessment.joins(:client).defaults
    scores_hash = default_assessments.map {|assessment| [assessment.client_id, assessment, assessment.basic_info] }.group_by(&:first)

    clients_array = clients.map do |client|
      enrollment_count   = client.client_enrollments.map(&:status).count{|status| status == 'Active'}
      assessments   = scores_hash[client.id] || []
      assessment = assessments.map(&:second).flatten.max_by(&:created_at)
      if assessment.present?
        assessment_domains = assessment.assessment_domains.pluck(:domain_id, :score).to_h
        domain_scores = csi_domains.map{ |domain| assessment_domains[domain.id] } if assessment_domains.present?
      else
        domain_scores = (1..12).map{ |_| '' }
      end
      { client: client, scores: assessments.present? ? assessments.map(&:last).flatten : [], assessment_count: assessments.flatten.count, enrollment_count: enrollment_count, domain_scores: domain_scores, short_name: short_name }
    end
  end

  def map_non_assessment_clients(clients, short_name)
    clients_array = clients.map do |client|
      { client: client, scores: [], assessment_count: 0, enrollment_count: 0, domain_scores: (1..12).map{ |_| '' }, short_name: short_name }
    end
  end
end
