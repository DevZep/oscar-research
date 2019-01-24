class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  protect_from_forgery with: :exception
  before_action :switch_organization, :set_locale

  def switch_organization
    Organization.switch_to 'public'
  end

  def set_locale
    locale = I18n.available_locales.include?(params[:locale].to_sym) ? params[:locale] : I18n.locale if params[:locale].present?
    I18n.locale = locale || I18n.locale
  end
end
