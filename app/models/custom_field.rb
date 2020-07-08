class CustomField < ActiveRecord::Base
  FREQUENCIES  = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze
  ENTITY_TYPES = ['Client', 'Family', 'Partner', 'User'].freeze

  has_many :custom_field_properties, dependent: :restrict_with_error
  has_many :clients, through: :custom_field_properties, source: :custom_formable, source_type: 'Client'

  scope :by_form_title,  ->(value)  { where('form_title iLIKE ?', "%#{value.squish}%") }
  scope :client_forms,   ->         { where(entity_type: 'Client') }
  scope :not_used_forms, ->(value)  { where.not(id: value) }
  scope :ordered_by,     ->(column) { order(column) }
  scope :order_by_form_title, ->    { order(:form_title) }

end
