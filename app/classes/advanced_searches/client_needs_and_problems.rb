module AdvancedSearches
  class ClientNeedsAndProblems
    # extend AdvancedSearchHelper

    # def self.render
    #   form_one_group  = format_header('form_one')
    #   needs_and_problems = client_needs_and_problems
    #   need_fields  = needs_and_problems[:client_needs].map { |item| number_options(item, client_needs_and_problems_format(item), form_one_group) }
    #   problem_fields  = needs_and_problems[:client_problems].map { |item| number_options(item, client_needs_and_problems_format(item), form_one_group) }
    #   need_fields + problem_fields
    # end

    # private

    # def self.client_needs_and_problems_format(label)
    #   label.split('_').last
    # end

    # def self.number_options(field_name, label, group)
    #   {
    #     id: field_name,
    #     optgroup: group,
    #     label: label,
    #     type: 'integer',
    #     operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty', 'is_not_empty']
    #   }
    # end

    # def self.client_needs_and_problems
    #   client_needs = []
    #   client_problems = []
    #   org_short_names = Organization.cambodian.visible.pluck(:short_name)
    #   org_short_names.each do |short_name|
    #     Organization.switch_to(short_name)
    #     client_needs.push(Need.all.map{|n| "need_#{n.name}"})
    #     client_problems.push(Problem.all.map{|p| "problem_#{p.name}"})
    #   end
    #   Organization.switch_to('public')
    #   { client_needs: client_needs.flatten(1).uniq, client_problems: client_problems.flatten(1).uniq }
    # end
  end
end
