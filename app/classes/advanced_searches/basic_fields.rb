module AdvancedSearches
  class BasicFields
    include ApplicationHelper
    include AdvancedSearchHelper

    def initialize(options = {})
      @user = options[:user]
    end

    def render
      group             = format_header('basic_fields')
      number_fields     = number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_header(item), group) }
      drop_list_fields  = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, group) }
      default_domain_scores_options = AdvancedSearches::DomainScoreFields.render
      search_fields     = number_fields + drop_list_fields + default_domain_scores_options
      search_fields.sort_by { |f| f[:label].downcase }
    end

    private

    def number_type_list
      ['basicfield_date_of_birth', 'active_program_stream']
    end

    def drop_down_type_list
      [
        ['basicfield_gender', { female: 'Female', male: 'Male' }],
        ['basicfield_status', client_status],
        ['basicfield_birth_province.name', provinces],
        ['basicfield_current_province.name', provinces],
        ['basicfield_district.name', districts]
      ]
    end

    def client_status
      Client::CLIENT_STATUSES.sort.map { |s| { s => s.capitalize } }
    end

    # def active_program_options
    #   enrollments = []
    #   org_short_names = Organization.cambodian.visible.pluck(:short_name)
    #   org_short_names.each do |short_name|
    #     Organization.switch_to(short_name)
    #     program_ids = ClientEnrollment.active.pluck(:program_stream_id).uniq
    #     enrollments << ProgramStream.where(id: program_ids).order(:name).map { |ps| { ps.id.to_s => ps.name } }
    #   end
    #   Organization.switch_to('public')

    #   enrollments.flatten.uniq
    # end

    def provinces
      org_short_names = Organization.cambodian.visible.pluck(:short_name)
      provinces = []
      org_short_names.map do |short_name|
        Organization.switch_to(short_name)
        next unless org_sharing_data?
        provinces << Province.all.pluck(:name, :id)
      end
      Organization.switch_to('public')
      provinces.flatten(1).uniq(&:first).sort.map{ |s| { s[0] => s[0] } }
    end

    def districts
      org_short_names = Organization.cambodian.visible.pluck(:short_name)
      districts = []
      org_short_names.map do |short_name|
        Organization.switch_to(short_name)
        next unless org_sharing_data?
        districts << District.all.pluck(:name, :id)
      end
      Organization.switch_to('public')
      districts.flatten(1).uniq(&:first).sort.map{ |s| { s[0] => s[0] } }
    end
  end
end
