class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :switch_organization, :set_locale
  protect_from_forgery with: :null_session, if: proc { |c| c.request.format == 'application/json' }

  def switch_organization
    Organization.switch_to 'public'
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: t('unauthorized.default')
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_url
  end

  def set_locale
    locale = I18n.available_locales.include?(params[:locale].to_sym) ? params[:locale] : I18n.locale if params[:locale].present?
    I18n.locale = locale || I18n.locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge(options)
  end

end
