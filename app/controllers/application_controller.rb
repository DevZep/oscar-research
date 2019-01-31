class ApplicationController < ActionController::Base
  include Pundit

  before_action :authenticate_user!
  before_action :switch_organization, :set_locale
  protect_from_forgery with: :null_session, if: proc { |c| c.request.format == 'application/json' }

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render file: "#{Rails.root}/app/views/errors/404", layout: false, status: :not_found
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_url
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge(options)
  end

  private

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
