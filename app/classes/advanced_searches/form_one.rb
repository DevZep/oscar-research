module AdvancedSearches
  class  FormOne
    include AdvancedSearchHelper

    def initialize(options = {})
      @user = options[:user]
    end

    def render
      group                             = format_header('form_one')
      number_fields                     = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_header(item), group) }
      text_fields                       = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), group) }
      date_picker_fields                = date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_header(item), group) }
      drop_list_fields                  = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, group) }
      # needs_and_problems_number_fields  = AdvancedSearches::ClientNeedsAndProblems.render
      basic_fields                      = AdvancedSearches::BasicFields.render
      search_fields                     = text_fields + drop_list_fields + number_fields + date_picker_fields

      # basic_fields + search_fields.sort_by { |f| f[:label].downcase } + needs_and_problems_number_fields
      basic_fields + search_fields.sort_by { |f| f[:label].downcase }
    end

    private

    def number_type_list
      ['age']
    end

    def text_type_list
      ['given_name', 'family_name', 'local_given_name', 'local_family_name', 'slug', 'house_number', 'street_number', 'code',
      'gov_city', 'gov_district', 'gov_commune', 'gov_village_code', 'gov_client_code', 'gov_interview_village', 'gov_interview_commune', 'gov_interview_district',
      'gov_interview_city', 'gov_caseworker_name', 'gov_caseworker_phone', 'gov_carer_name', 'gov_carer_relationship', 'gov_carer_home', 'gov_carer_street',
      'gov_carer_village', 'gov_carer_commune', 'gov_carer_district', 'gov_carer_city', 'gov_carer_phone']
    end

    def date_type_list
      ['date_of_birth']
    end

    def drop_down_type_list
      [
        ['gender', { female: 'Female', male: 'Male' }],
        ['current_province', provinces],
        ['district', districts],
        ['commune', communes],
        ['village', villages],
      ]
    end

    def provinces
      org_short_names = Organization.cambodian.visible.pluck(:short_name)
      provinces = org_short_names.map do |short_name|
        Organization.switch_to(short_name)
        Province.all.pluck(:name, :id)
      end
      Organization.switch_to('public')
      provinces.flatten(1).uniq(&:first).sort.map{ |s| { s[0] => s[0] } }
    end

    def districts
      org_short_names = Organization.cambodian.visible.pluck(:short_name)
      districts = org_short_names.map do |short_name|
        Organization.switch_to(short_name)
        District.all.pluck(:name, :id)
      end
      Organization.switch_to('public')
      districts.flatten(1).uniq(&:first).sort.map{ |s| { s[0] => s[0] } }
    end

    def communes
      org_short_names = Organization.cambodian.visible.pluck(:short_name)
      communes = org_short_names.map do |short_name|
        Organization.switch_to(short_name)
        Commune.all.map { |c|  [c.name, c.id] }
      end
      Organization.switch_to('public')
      communes.flatten(1).uniq(&:first).sort.map{ |s| { s[0] => s[0] } }
    end

    def villages
      org_short_names = Organization.cambodian.visible.pluck(:short_name)
      villages = org_short_names.map do |short_name|
        Organization.switch_to(short_name)
        Village.all.map { |v|  [v.name, v.id] }
      end
      Organization.switch_to('public')
      villages.flatten(1).uniq(&:first).sort.map{ |s| { s[0] => s[0] } }
    end
  end
end
