module AdvancedSearches
  class BasicFields
    extend AdvancedSearchHelper

    def self.render
      group                 = format_header('basic_fields')
      ngos = ['basicfield_NGO', all_ngos]
      # text_fields               = text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_header(item), group) }
      drop_list_fields          = drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_header(item.first), item.last, group) }
      drop_list_fields << drop_list_ngos(ngos.first, format_header(ngos.first), ngos.last, group)
      search_fields         = drop_list_fields
      search_fields.sort_by { |f| f[:label].downcase }
    end

    private

    def self.text_type_list
      ['basicfield_given_name', 'basicfield_family_name', 'basicfield_local_given_name', 'basicfield_local_family_name', 'basicfield_slug']
    end

    def self.drop_down_type_list
      [
        ['basicfield_gender', { female: 'Female', male: 'Male' }]
      ]
    end

    def self.all_ngos
      Organization.cambodian.visible.order('lower(full_name)').pluck(:short_name, :full_name).map{ |s| { s[0] => s[1] } }
    end

    def self.drop_list_ngos(field_name, label, values, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        type: 'string',
        input: 'select',
        values: values,
        operators: ['equal', 'not_equal']
      }
    end
  end
end
