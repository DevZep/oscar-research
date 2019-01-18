class AdminController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :set_sidebar_basic_info

  def set_sidebar_basic_info
    @user_count    = User.only_from_oscar_research.count
    @client_count  = all_clients.count
  end

  def all_clients
    org_short_names = Organization.cambodian.visible.pluck(:short_name)
    clients = org_short_names.map do |short_name|
      Organization.switch_to(short_name)
      Client.all.reload
    end
    Organization.switch_to('public')
    clients.flatten
  end
end
