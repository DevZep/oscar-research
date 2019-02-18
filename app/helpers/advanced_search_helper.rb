module AdvancedSearchHelper
  def exit_form_check
    has_advanced_search? && advanced_search_params[:exit_form_check].present? ? true : false
  end

  def has_advanced_search?
    params[:client_advanced_search].present?
  end

  def advanced_search_params
    params[:client_advanced_search]
  end

  def format_header(key)
    translations = {
      active_program_stream: I18n.t('custom_table.form_one_title.active_program_stream'),
      age: I18n.t('custom_table.form_one_title.age'),
      basic_fields: I18n.t('custom_table.basic_fields'),
      basicfield_gender: I18n.t('custom_table.form_one_title.gender'),
      current_province: I18n.t('custom_table.form_one_title.current_province'),
      district: I18n.t('custom_table.form_one_title.district'),
      form_one: I18n.t('custom_table.form_one_title.government_form_one'),
      gender: I18n.t('custom_table.form_one_title.gender'),
      status: I18n.t('custom_table.form_one_title.status')
    }
    translations[key.to_sym] || ''
  end
end
