class CustomFieldProperty < ActiveRecord::Base
  belongs_to :custom_formable, polymorphic: true
  belongs_to :custom_field


  scope :by_custom_field, -> (value) { where(custom_field:  value) }
  scope :most_recents,    ->         { order('created_at desc') }


  def client_form?
    custom_formable_type == 'Client'
  end

  def self.properties_by(value)
    value = value.gsub(/\'+/, "''")
    field_properties = select("custom_field_properties.id, custom_field_properties.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end
end
