module GenerateClientExcel
  def client_report(clients)
    import_client_report(clients)
  end

  private

  def import_client_report(clients)
    if @advanced_search_params.present? && @advanced_search_params[:basic_rules].present? && params[:default_column].nil?
      gender_excel_by_report_builder(clients)
    else
      gender_excel_by_client_default(clients)
    end
  end

  def format_yes_no(value)
    value ? 'Yes' : 'No'
  end

  def client_default_columns
    columns = [I18n.t('custom_table.form_one_title.slug'), I18n.t('custom_table.form_one_title.given_name'), I18n.t('custom_table.form_one_title.family_name'), I18n.t('custom_table.form_one_title.local_given_name'), I18n.t('custom_table.form_one_title.local_family_name'), I18n.t('custom_table.form_one_title.gender'), I18n.t('custom_table.form_one_title.date_of_birth'), I18n.t('custom_table.form_one_title.current_province'), I18n.t('custom_table.form_one_title.gov_caseworker_name')]
  end

  def client_default_values(client)
    values = [client.slug, client.given_name, client.family_name, client.local_given_name, client.family_name, client.gender, client.date_of_birth, client.province, client.gov_caseworker_name]
  end

  def columns_report_builder
    columns = []
    columns << I18n.t('custom_table.form_one_title.slug') if params[:columns].nil? || params[:columns][:slug] == '1'
    columns << I18n.t('custom_table.form_one_title.ngo') if params[:columns].nil? || params[:columns][:ngo] == '1'
    columns << I18n.t('custom_table.form_one_title.code') if params[:columns].nil? || params[:columns][:code] == '1'
    columns << I18n.t('custom_table.form_one_title.given_name') if params[:columns].nil? || params[:columns][:given_name] == '1'
    columns << I18n.t('custom_table.form_one_title.family_name') if params[:columns].nil? || params[:columns][:family_name] == '1'
    columns << I18n.t('custom_table.form_one_title.local_given_name') if params[:columns].nil? || params[:columns][:local_given_name] == '1'
    columns << I18n.t('custom_table.form_one_title.local_family_name') if params[:columns].nil? || params[:columns][:local_family_name] == '1'
    columns << I18n.t('custom_table.form_one_title.gender') if params[:columns].nil? || params[:columns][:gender] == '1'
    columns << I18n.t('custom_table.form_one_title.date_of_birth') if params[:columns].nil? || params[:columns][:date_of_birth] == '1'
    columns << I18n.t('custom_table.form_one_title.age') if params[:columns].nil? || params[:columns][:age] == '1'
    columns << I18n.t('custom_table.form_one_title.current_address') if params[:columns].nil? || params[:columns][:current_address] == '1'
    columns << I18n.t('custom_table.form_one_title.house_number') if params[:columns].nil? || params[:columns][:house_number] == '1'
    columns << I18n.t('custom_table.form_one_title.street_number') if params[:columns].nil? || params[:columns][:street_number] == '1'
    columns << I18n.t('custom_table.form_one_title.village') if params[:columns].nil? || params[:columns][:village] == '1'
    columns << I18n.t('custom_table.form_one_title.commune') if params[:columns].nil? || params[:columns][:commune] == '1'
    columns << I18n.t('custom_table.form_one_title.district') if params[:columns].nil? || params[:columns][:district] == '1'
    columns << I18n.t('custom_table.form_one_title.current_province') if params[:columns].nil? || params[:columns][:current_province] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_city') if params[:columns].nil? || params[:columns][:gov_city] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_district') if params[:columns].nil? || params[:columns][:gov_district] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_commune') if params[:columns].nil? || params[:columns][:gov_commune] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_date') if params[:columns].nil? || params[:columns][:gov_date] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_village_code') if params[:columns].nil? || params[:columns][:gov_village_code] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_client_code') if params[:columns].nil? || params[:columns][:gov_client_code] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_interview_village') if params[:columns].nil? || params[:columns][:gov_interview_village] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_interview_commune') if params[:columns].nil? || params[:columns][:gov_interview_commune] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_interview_district') if params[:columns].nil? || params[:columns][:gov_interview_district] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_interview_city') if params[:columns].nil? || params[:columns][:gov_interview_city] == '1'
    columns << I18n.t('custom_table.form_one_title.interviewees_place_of_interview') if params[:columns].nil? || params[:columns][:interviewees_place_of_interview] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_caseworker_name') if params[:columns].nil? || params[:columns][:gov_caseworker_name] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_caseworker_phone') if params[:columns].nil? || params[:columns][:gov_caseworker_phone] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_carer_name') if params[:columns].nil? || params[:columns][:gov_carer_name] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_carer_relationship') if params[:columns].nil? || params[:columns][:gov_carer_relationship] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_carer_home') if params[:columns].nil? || params[:columns][:gov_carer_home] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_carer_street') if params[:columns].nil? || params[:columns][:gov_carer_street] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_carer_village') if params[:columns].nil? || params[:columns][:gov_carer_village] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_carer_commune') if params[:columns].nil? || params[:columns][:gov_carer_commune] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_carer_district') if params[:columns].nil? || params[:columns][:gov_carer_district] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_carer_city') if params[:columns].nil? || params[:columns][:gov_carer_city] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_carer_phone') if params[:columns].nil? || params[:columns][:gov_carer_phone] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_information_source') if params[:columns].nil? || params[:columns][:gov_information_source] == '1'
    columns << I18n.t('custom_table.form_one_title.client_types') if params[:columns].nil? || params[:columns][:client_types] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_referral_reason') if params[:columns].nil? || params[:columns][:gov_referral_reason] == '1'
    columns << I18n.t('custom_table.form_one_title.gov_guardian_comment') if params[:columns].nil? || params[:columns][:gov_guardian_comment] == '1'

    @client_needs.each do |need|
      columns << need.name if params[:columns].nil? || params[:columns]["need_#{need.id}"] == '1'
    end
    @client_problems.each do |problem|
      columns << problem.name if params[:columns].nil? || params[:columns]["problem_#{problem.id}"] == '1'
    end
    columns << I18n.t('custom_table.form_one_title.caseworker_comment') if params[:columns].nil? || params[:columns][:caseworker_comment] == '1'
    columns
  end

  def values_report_builder(client)
    values = []
    values << client.slug if params[:columns].nil? || params[:columns][:slug] == '1'
    values << Organization.current.full_name if params[:columns].nil? || params[:columns][:ngo] == '1'
    values << client.code if params[:columns].nil? || params[:columns][:code] == '1'
    values << client.given_name if params[:columns].nil? || params[:columns][:given_name] == '1'
    values << client.family_name   if params[:columns].nil? || params[:columns][:family_name] == '1'
    values << client.local_given_name if params[:columns].nil? || params[:columns][:local_given_name] == '1'
    values << client.local_family_name if params[:columns].nil? || params[:columns][:local_family_name] == '1'
    values << client.gender if params[:columns].nil? || params[:columns][:gender] == '1'
    values << client.date_of_birth if params[:columns].nil? || params[:columns][:date_of_birth] == '1'
    values << client.age_as_years if params[:columns].nil? || params[:columns][:age] == '1'
    values << client.current_address if params[:columns].nil? || params[:columns][:current_address] == '1'
    values << client.house_number if params[:columns].nil? || params[:columns][:house_number] == '1'
    values << client.street_number if params[:columns].nil? || params[:columns][:street_number] == '1'
    values << client.village if params[:columns].nil? || params[:columns][:village] == '1'
    values << client.commune if params[:columns].nil? || params[:columns][:commune] == '1'
    values << client.district.try(:name) if params[:columns].nil? || params[:columns][:district] == '1'
    values << client.province if params[:columns].nil? || params[:columns][:current_province] == '1'
    values << client.gov_city if params[:columns].nil? || params[:columns][:gov_city] == '1'
    values << client.gov_district if params[:columns].nil? || params[:columns][:gov_district] == '1'
    values << client.gov_commune if params[:columns].nil? || params[:columns][:gov_commune] == '1'
    values << client.gov_date if params[:columns].nil? || params[:columns][:gov_date] == '1'
    values << client.gov_village_code if params[:columns].nil? || params[:columns][:gov_village_code] == '1'
    values << client.gov_client_code if params[:columns].nil? || params[:columns][:gov_client_code] == '1'
    values << client.gov_interview_village if params[:columns].nil? || params[:columns][:gov_interview_village] == '1'
    values << client.gov_interview_commune if params[:columns].nil? || params[:columns][:gov_interview_commune] == '1'
    values << client.district if params[:columns].nil? || params[:columns][:gov_interview_district] == '1'
    values << client.gov_interview_city if params[:columns].nil? || params[:columns][:gov_interview_city] == '1'
    values << client.interviewees.pluck(:name).joins(', ') if params[:columns].nil? || params[:columns][:interviewees_place_of_interview] == '1'
    values << client.gov_caseworker_name if params[:columns].nil? || params[:columns][:gov_caseworker_name] == '1'
    values << client.gov_caseworker_phone if params[:columns].nil? || params[:columns][:gov_caseworker_phone] == '1'
    values << client.gov_carer_name if params[:columns].nil? || params[:columns][:gov_carer_name] == '1'
    values << client.gov_carer_relationship if params[:columns].nil? || params[:columns][:gov_carer_relationship] == '1'
    values << client.gov_carer_home if params[:columns].nil? || params[:columns][:gov_carer_home] == '1'
    values << client.gov_carer_street if params[:columns].nil? || params[:columns][:gov_carer_street] == '1'
    values << client.gov_carer_village if params[:columns].nil? || params[:columns][:gov_carer_village] == '1'
    values << client.gov_carer_commune if params[:columns].nil? || params[:columns][:gov_carer_commune] == '1'
    values << client.gov_carer_district if params[:columns].nil? || params[:columns][:gov_carer_district] == '1'
    values << client.gov_carer_city if params[:columns].nil? || params[:columns][:gov_carer_city] == '1'
    values << client.gov_carer_phone if params[:columns].nil? || params[:columns][:gov_carer_phone] == '1'
    values << client.gov_information_source if params[:columns].nil? || params[:columns][:gov_information_source] == '1'
    values << client.client_types.joins(', ') if params[:columns].nil? || params[:columns][:client_types] == '1'
    values << client.gov_referral_reason if params[:columns].nil? || params[:columns][:gov_referral_reason] == '1'
    values << client.gov_guardian_comment if params[:columns].nil? || params[:columns][:gov_guardian_comment] == '1'

    @client_needs.each do |need|
      values << need_rank(client, need.name) if params[:columns].nil? || params[:columns]["need_#{need.id}"] == '1'
    end

    @client_problems.each do |problem|
      values << problem_rank(client, problem.name) if params[:columns].nil? || params[:columns]["problem_#{problem.id}"] == '1'
    end

    values << client.gov_caseworker_comment if params[:columns].nil? || params[:columns][:caseworker_comment] == '1'
    values
  end

  def gender_excel_by_client_default(clients)
    column_names = client_default_columns
    book = Spreadsheet::Workbook.new
    worksheet          = book.create_worksheet
    book.worksheet(0).insert_row(0, column_names)
    header_format = Spreadsheet::Format.new(
      horizontal_align: :center,
      vertical_align: :center,
      shrink: true,
      border: :thin,
      size: 11
    )
    column_format = Spreadsheet::Format.new(
      shrink: true,
      border: :thin,
      size: 11
    )
    column_date_format = Spreadsheet::Format.new(
      shrink: true,
      border: :thin,
      size: 11,
      number_format: 'mmmm d, yyyy'
    )

    worksheet.row(0).height = 30
    clients.each_with_index do |client, index|
      Organization.switch_to(client.slug.split('-').first)
      values = client_default_values(client)
      worksheet.insert_row(index += 1, values)
    end
    Organization.switch_to('public')
    buffer = StringIO.new
    book.write(buffer)
    buffer.rewind
    buffer.read
  end

  def gender_excel_by_report_builder(clients)
    column_names = columns_report_builder
    book = Spreadsheet::Workbook.new
    worksheet          = book.create_worksheet
    book.worksheet(0).insert_row(0, column_names)
    header_format = Spreadsheet::Format.new(
      horizontal_align: :center,
      vertical_align: :center,
      shrink: true,
      border: :thin,
      size: 11
    )
    column_format = Spreadsheet::Format.new(
      shrink: true,
      border: :thin,
      size: 11
    )
    column_date_format = Spreadsheet::Format.new(
      shrink: true,
      border: :thin,
      size: 11,
      number_format: 'mmmm d, yyyy'
    )

    worksheet.row(0).height = 30
    clients.each_with_index do |client, index|
      Organization.switch_to(client.slug.split('-').first)
      values = values_report_builder(client)
      worksheet.insert_row(index += 1, values)
    end
    Organization.switch_to('public')
    buffer = StringIO.new
    book.write(buffer)
    buffer.rewind
    buffer.read
  end

  def need_rank(client, need)
    need = Need.find_by(name: need)
    return '' unless need.present?
    client.client_needs.find_by(need_id: need.id).try(:rank)
  end

  def problem_rank(client, problem)
    problem = Problem.find_by(name: problem)
    return '' unless problem.present?
    client.client_problems.find_by(problem_id: problem.id).try(:rank)
  end
end
