module ApplicationHelper
  def flash_alert
    if notice
      { 'message-type': 'notice', 'message': notice }
    elsif alert
      { 'message-type': 'alert', 'message': alert }
    else
      {}
    end
  end

  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end

  def authorized_body
    'unauthorized-background' unless user_signed_in?
  end

  def clients_menu_active
    names = %w(clients client_advanced_searches)
    any_active_menu(names)
  end

  def error_notification(f)
    content_tag(:div, t('review_problem'), class: 'alert alert-danger') if f.error_notification.present?
  end

  def current_url(new_params)
    url_for params: params.merge(new_params)
  end

  def any_active_menu(names)
    'active' if names.include? controller_name
  end

  def date_format(date)
    date.strftime('%d %B %Y') if date.present?
  end
end
