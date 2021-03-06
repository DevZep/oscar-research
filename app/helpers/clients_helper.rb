module ClientsHelper
  def show_all_columns
    if params[:columns].nil?
      show = '1'
    else
      if params[:columns][:show_all] == '1'
        show = '1'
      else
        show = '0'
      end
    end
    return true if show == '1'
  end

  def check_if_true(item)
    if params[:columns].nil? || params[:columns][item] == '1'
      return true
    else
      return false
    end
  end

  def merged_address(client)
    current_address = []

    if locale == :km
      current_address << client.district_name.split(' / ').first if client.district.present?
      current_address << client.province_name.split(' / ').first if client.province.present?
    else
      current_address << client.district_name.split(' / ').last if client.district.present?
      current_address << client.province_name.split(' / ').last if client.province.present?
    end
    country = I18n.t('custom_table.form_one_title.cambodia')
    current_address << country
    current_address.compact.join(', ')
  end

  def case_worker_options(case_workers)
    case_workers.map{|c| [c.split(' _ ').last, c.split(' _ ').first]}
  end

  def list_names(names)
    content_tag(:ul) do
      names.collect do |name|
        content_tag(:li, name)
      end.join.html_safe
    end
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

  def all_csi_assessment_lists(scores)
    content_tag(:ul) do
      scores.each do |score|
        concat(content_tag(:li, score))
      end
    end
  end

  def domain_header
    content_tag(:div) do
      Domain.csi_domains.order_by_name.map do |domain|
        concat content_tag(:th, domain.identity, class: 'text-center')
      end
    end
  end

  def domain_cell_data(domain_scores)
    content_tag(:div) do
      domain_scores.map do |score|
        concat content_tag(:td, score, class: 'text-center')
      end
    end
  end
end
