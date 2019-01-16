class Dashboard
  include Rails.application.routes.url_helpers
  attr_reader :clients

  def initialize(clients)
    @clients  = clients
  end

  def client_ages
    [
      { name: '0-3', y: @clients[:client_age_zero_to_three].count, url: url_ages_basic_filter(['0','3']) },
      { name: '4-6', y: @clients[:client_age_four_to_six].count, url: url_ages_basic_filter(['4','6']) },
      { name: '6-11', y: @clients[:client_age_six_to_eleven].count, url: url_ages_basic_filter(['6','11']) },
      { name: '11-14', y: @clients[:client_age_eleven_to_fourteen].count, url: url_ages_basic_filter(['11','14']) },
      { name: '14-18', y: @clients[:client_age_fourteen_to_eighteen].count, url: url_ages_basic_filter(['14','18']) }
    ]
  end

  private

  def url_ages_basic_filter(ages)
    url = { 'condition': 'AND', 'rules': [{ 'id': 'age', 'field': 'age', 'type': 'integer', 'input': 'number', 'operator': 'between', 'value': ages } ]}
    clients_path('client_advanced_search[basic_rules]': url.to_json, default_column: :true)
  end
end
