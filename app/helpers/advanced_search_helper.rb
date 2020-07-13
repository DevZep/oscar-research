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
      active_program_stream: I18n.t('custom_table.active_program_stream'),
      basicfield_date_of_birth: I18n.t('custom_table.form_one_title.age'),
      basic_fields: I18n.t('custom_table.basic_fields'),
      basicfield_gender: I18n.t('custom_table.form_one_title.gender'),
      csi_domain_scores: I18n.t('custom_table.csi_domain_scores'),
      basicfield_birth_province: I18n.t('custom_table.form_one_title.birth_province'),
      basicfield_current_province: I18n.t('custom_table.form_one_title.current_province'),
      basicfield_district: I18n.t('custom_table.form_one_title.district'),
      form_one: I18n.t('custom_table.form_one_title.government_form_one'),
      basicfield_gender: I18n.t('custom_table.form_one_title.gender'),
      basicfield_status: I18n.t('custom_table.form_one_title.status')
    }
    translations[key.to_sym] || ''
  end
end
