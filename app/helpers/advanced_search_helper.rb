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
      slug: I18n.t('custom_table.form_one_title.slug'),
      date_of_birth: I18n.t('custom_table.form_one_title.date_of_birth'),
      given_name: I18n.t('custom_table.form_one_title.given_name'),
      family_name: I18n.t('custom_table.form_one_title.family_name'),
      local_given_name: I18n.t('custom_table.form_one_title.local_given_name'),
      local_family_name: I18n.t('custom_table.form_one_title.local_family_name'),
      code: I18n.t('custom_table.form_one_title.code'),
      age: I18n.t('custom_table.form_one_title.age'),
      house_number: I18n.t('custom_table.form_one_title.house_number'),
      street_number: I18n.t('custom_table.form_one_title.street_number'),
      village: I18n.t('custom_table.form_one_title.village'),
      commune: I18n.t('custom_table.form_one_title.commune'),
      district: I18n.t('custom_table.form_one_title.district'),
      gender: I18n.t('custom_table.form_one_title.gender'),
      birth_province: I18n.t('custom_table.form_one_title.birth_province'),
      current_province: I18n.t('custom_table.form_one_title.current_province'),
      form_one: I18n.t('custom_table.form_one_title.government_form_one'),
      gov_city: I18n.t('custom_table.form_one_title.gov_city'),
      gov_district: I18n.t('custom_table.form_one_title.gov_district'),
      gov_commune: I18n.t('custom_table.form_one_title.gov_commune'),
      gov_date: I18n.t('custom_table.form_one_title.gov_date'),
      gov_village_code: I18n.t('custom_table.form_one_title.gov_village_code'),
      gov_client_code: I18n.t('custom_table.form_one_title.gov_client_code'),
      gov_interview_village: I18n.t('custom_table.form_one_title.gov_interview_village'),
      gov_interview_commune: I18n.t('custom_table.form_one_title.gov_interview_commune'),
      gov_interview_district: I18n.t('custom_table.form_one_title.gov_interview_district'),
      gov_interview_city: I18n.t('custom_table.form_one_title.gov_interview_city'),
      gov_caseworker_name: I18n.t('custom_table.form_one_title.gov_caseworker_name'),
      gov_caseworker_phone: I18n.t('custom_table.form_one_title.gov_caseworker_phone'),
      gov_carer_name: I18n.t('custom_table.form_one_title.gov_carer_name'),
      gov_carer_relationship: I18n.t('custom_table.form_one_title.gov_carer_relationship'),
      gov_carer_home: I18n.t('custom_table.form_one_title.gov_carer_home'),
      gov_carer_street: I18n.t('custom_table.form_one_title.gov_carer_street'),
      gov_carer_village: I18n.t('custom_table.form_one_title.gov_carer_village'),
      gov_carer_commune: I18n.t('custom_table.form_one_title.gov_carer_commune'),
      gov_carer_district: I18n.t('custom_table.form_one_title.gov_carer_district'),
      gov_carer_city: I18n.t('custom_table.form_one_title.gov_carer_city'),
      gov_carer_phone: I18n.t('custom_table.form_one_title.gov_carer_phone'),
      gov_information_source: I18n.t('custom_table.form_one_title.gov_information_source'),
      client_types: I18n.t('custom_table.form_one_title.client_types'),
      gov_referral_reason: I18n.t('custom_table.form_one_title.gov_referral_reason'),
      gov_guardian_comment: I18n.t('custom_table.form_one_title.gov_guardian_comment'),
      basic_fields: I18n.t('custom_table.basic_fields'),
      basicfield_given_name: I18n.t('custom_table.form_one_title.given_name'),
      basicfield_family_name: I18n.t('custom_table.form_one_title.family_name'),
      basicfield_local_given_name: I18n.t('custom_table.form_one_title.local_given_name'),
      basicfield_local_family_name: I18n.t('custom_table.form_one_title.local_family_name'),
      basicfield_slug: I18n.t('custom_table.form_one_title.slug'),
      basicfield_NGO: I18n.t('custom_table.form_one_title.ngo'),
      basicfield_gender: I18n.t('custom_table.form_one_title.gender')
    }
    translations[key.to_sym] || ''
  end
end
