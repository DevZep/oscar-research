class AdminController < ApplicationController
  include ApplicationHelper
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :set_sidebar_basic_info

  def set_sidebar_basic_info
    @client_count  = all_clients
    @user_count    = User.count
  end

  def all_clients
    org_short_names = Organization.cambodian.visible.pluck(:short_name)
    clients = 0
    org_short_names.each do |short_name|
      Organization.switch_to(short_name)
      next unless org_sharing_data?
      clients += Client.count
    end
    Organization.switch_to('public')
    clients
  end
end
