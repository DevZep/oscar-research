class ApplicationController < ActionController::Base
  include Pundit

  before_action :authenticate_user!

  protect_from_forgery with: :exception
  before_action :switch_organization, :set_locale

  def switch_organization
    Organization.switch_to 'public'
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    redirect_to root_url, alert: 'You are not authorized to access this page.'
  end

  def set_locale
    locale = I18n.available_locales.include?(params[:locale].to_sym) ? params[:locale] : I18n.locale if params[:locale].present?
    I18n.locale = locale || I18n.locale
  end
end
