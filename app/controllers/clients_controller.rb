class ClientsController < AdminController
  before_action :find_params_advanced_search, :client_builder_fields, :build_advanced_search, only: :index
  before_action :basic_params, if: :has_params?
  before_action :find_client, :find_csi_domains, only: :show

  def index
    respond_to do |f|
      clients = list_clients_filter
      f.html do
        @clients_count = clients.count
        @clients = clients
      end
    end
  end

  def show
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
    org_short_names = Organization.cambodian.visible.pluck(:short_name)
    all_clients = []
    org_short_names.each do |short_name|
      Organization.switch_to(short_name)
      next unless Setting.first.sharing_data?
      clients = clients_query
      all_clients << { ngo: short_name, clients: clients.flatten }
    end
    Organization.switch_to('public')
    all_clients
  end

  def decorate_clients(value)
    ClientDecorator.decorate(value)
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
    all_clients = []
    ngos.each do |short_name|
      Organization.switch_to(short_name)
      next unless Setting.first.sharing_data?
      clients = AdvancedSearches::ClientAdvancedSearch.new(basic_rules, clients_query).filter.reload
      all_clients << { ngo: short_name, clients: clients.flatten }
    end
    Organization.switch_to('public')
    all_clients
  end

  def clients_query
    Client.includes(:province, :district)
          .select("id, slug, date_of_birth, status, gender, province_id, district_id,
                  (SELECT COUNT(id) FROM client_enrollments WHERE client_enrollments.client_id = clients.id AND status = 'Active') as enrollment_count,
                  (SELECT COUNT(id) FROM assessments WHERE assessments.client_id = clients.id AND assessments.default = true) as assessment_count
                ")
  end

  def find_client
    crypt = ActiveSupport::MessageEncryptor.new(ENV['SLUG_ENCRYPTION_KEY'])
    client_id  = crypt.decrypt_and_verify(params[:id])
    ngo_short_name = params[:ngo]

    Organization.switch_to(ngo_short_name)

    @client = clients_query.friendly.find(client_id)
  end

  def find_csi_domains
    @csi_domains = Domain.csi_domains
  end
end
