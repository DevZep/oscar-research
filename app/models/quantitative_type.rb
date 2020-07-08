class QuantitativeType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :quantitative_cases

  default_scope { order(name: :asc) }

  scope :name_like, ->(name) { where('quantitative_types.name iLIKE ?', "%#{name}%") }

end
