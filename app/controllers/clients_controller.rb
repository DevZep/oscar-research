class ClientsController < AdminController

  before_action :find_client, only: :show
  before_action :client_builder_fields, :build_advanced_search, :fetch_advanced_search_queries, only: :index
  before_action :basic_params, if: :has_params?

  def index
    respond_to do |f|
      f.html do
        clients = list_clients_filter
        @clients_count = clients.count
        @clients = Kaminari.paginate_array(clients).page(params[:page]).per(20)
      end
    end
  end

  def show
  end

  private

  def find_client
    ngo_short_name = params[:id].split('-').first
    Organization.switch_to(ngo_short_name)
    @client = decorate_clients(Client.friendly.find(params[:id]))
  end

  def clients_ordered(clients)
    clients = clients.sort_by(&:name)
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
    org_short_names = Organization.cambodian.visible.pluck(:short_name)
    clients = org_short_names.map do |short_name|
      Organization.switch_to(short_name)
      filtering_params(params).present? ? Client.filter(filtering_params(params)).reload : Client.all.reload
    end
    Organization.switch_to('public')
    clients.flatten
  end

  def decorate_clients(value)
    ClientDecorator.decorate(value)
  end

  def filtering_params(params)
    params.slice(:age, :status, :gender)
  end

  def client_case_workers
    # org_short_names = Organization.cambodian.visible.pluck(:short_name)
    # client_case_workers = org_short_names.map do |short_name|
    #   Organization.switch_to(short_name)
    #   User.has_clients.uniq.map{|user| "#{short_name}_#{user.id} _ #{user.name}"}
    # end
    # Organization.switch_to('public')
    # client_case_workers.flatten
  end

  def client_filter_adavnced_searches
    return unless has_params?
    basic_rules     = JSON.parse @basic_filter_params
    basicfield_ngo  = []
    org_short_names = Organization.cambodian.visible.pluck(:short_name)
    filter_client_advanced_serach(org_short_names, basic_rules)
  end

  def build_advanced_search
    @advanced_search = AdvancedSearch.new
  end

  def fetch_advanced_search_queries
    @my_advanced_searches    = current_user.advanced_searches.order(:name)
    @other_advanced_searches = AdvancedSearch.non_of(current_user).order(:name)
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
      clients = clients_ordered(fetch_clients)
    end
  end

  def filter_client_advanced_serach(ngos, basic_rules)
    clients = ngos.map do |short_name|
      Organization.switch_to(short_name)
      AdvancedSearches::ClientAdvancedSearch.new(basic_rules, Client.all).filter.reload
    end
    Organization.switch_to('public')
    clients.flatten
  end
end
