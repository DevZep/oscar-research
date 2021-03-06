class Carer < ActiveRecord::Base
  has_many :clients, dependent: :restrict_with_error

  CLIENT_RELATIONSHIPS = ['Parent', 'Grandparent', 'Aunt / Uncle', 'Sibling', 'Cousin', 'Family Friend', 'Foster Carer', 'Temporary Carer', 'RCI Carer', 'Adopted Parent', 'Other'].freeze
end
