class HomeController < ApplicationController
  def index
    redirect_to dashboard_path if user_signed_in?
    redirect_to new_user_session_path unless user_signed_in?
  end
end