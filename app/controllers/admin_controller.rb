class AdminController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :set_sidebar_basic_info

  def set_sidebar_basic_info
    @user_count    = User.count
  end
end
