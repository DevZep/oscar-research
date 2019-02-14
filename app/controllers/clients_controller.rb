class ClientsController < AdminController
  before_action :find_params_advanced_search, :build_advanced_search, :fetch_advanced_search_queries, only: :index
  before_action :basic_params, if: :has_params?

  def index
    respond_to do |f|
      clients = list_clients_filter
      f.html do
        @clients_count = clients.count
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
    clients = []
    org_short_names.each do |short_name|
      Organization.switch_to(short_name)
      next unless Setting.first.sharing_data?
      clients << clients_query
      clients.flatten.to_a
    end
    Organization.switch_to('public')
    clients.flatten
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

  def fetch_advanced_search_queries
    @my_advanced_searches    = current_user.advanced_searches.order(:name)
    @other_advanced_searches = AdvancedSearch.non_of(current_user).order(:name)
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
      next unless Setting.first.sharing_data?
      AdvancedSearches::ClientAdvancedSearch.new(basic_rules, clients_query).filter.reload
    end
    Organization.switch_to('public')
    clients.flatten
  end

  def clients_query
    Client.includes(:province, :district)
          .select("id, slug, date_of_birth, status, gender, province_id, district_id,
                  (SELECT COUNT(id) FROM client_enrollments WHERE client_enrollments.client_id = clients.id AND status = 'Active') as enrollment_count,
                  (SELECT COUNT(id) FROM assessments WHERE assessments.client_id = clients.id AND assessments.default = true) as assessment_count
                ")
  end
end
