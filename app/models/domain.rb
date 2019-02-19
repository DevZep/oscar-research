class Domain < ActiveRecord::Base
  belongs_to :domain_group, counter_cache: true

  has_many :assessment_domains, dependent: :restrict_with_error
  has_many :assessments, through: :assessment_domains
  has_many :domain_program_streams, dependent: :restrict_with_error
  has_many :program_streams, through: :domain_program_streams

  default_scope { order('domain_group_id ASC, name ASC') }
  scope :csi_domains, -> { where(custom_domain: false) }
  scope :order_by_identity, -> { order(:identity) }
end
