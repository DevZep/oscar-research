class Domain < ActiveRecord::Base
  belongs_to :domain_group, counter_cache: true
  belongs_to :custom_assessment_setting, required: false

  has_many :assessment_domains, dependent: :restrict_with_error
  has_many :assessments, through: :assessment_domains
  has_many :domain_program_streams, dependent: :restrict_with_error
  has_many :program_streams, through: :domain_program_streams

  scope :csi_domains, -> { where(custom_domain: false) }
  scope :custom_domains, -> { where(custom_domain: true) }
  scope :order_by_identity, -> { order(:identity) }
  scope :order_by_name, -> { order(:name) }
end
