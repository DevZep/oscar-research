class Assessment < ActiveRecord::Base
  belongs_to :client, counter_cache: true

  has_many :assessment_domains, dependent: :destroy
  has_many :domains,            through:   :assessment_domains

  has_paper_trail

  validates :client, presence: true
  validate :must_be_enable
  # validate :must_be_min_assessment_period, :eligible_client_age, :check_previous_assessment_status, if: :new_record?
  validate :allow_create, :eligible_client_age, if: :new_record?

  accepts_nested_attributes_for :assessment_domains

  scope :most_recents, -> { order(created_at: :desc) }
  scope :defaults, -> { where(default: true) }
  scope :customs, -> { where(default: false) }

  DUE_STATES        = ['Due Today', 'Overdue']


  def self.latest_record
    most_recents.first
  end

  def self.default_latest_record
    defaults.most_recents.first
  end

  def self.custom_latest_record
    customs.most_recents.first
  end

  def initial?
    if default?
      self == client.assessments.defaults.most_recents.last || client.assessments.defaults.count.zero?
    else
      self == client.assessments.customs.most_recents.last || client.assessments.customs.count.zero?
    end
  end

  def latest_record?
    self == client.assessments.latest_record
  end

  def basic_info
    "#{created_at.to_date} => #{assessment_domains_score}"
  end

  def assessment_domains_score
    domains.pluck(:name, :score).map { |item| item.join(': ') }.join(', ')
  end

  def assessment_domains_in_order
    assessment_domains.order('created_at')
  end

  def eligible_client_age
    return false if client.nil?

    eligible = default? ? client.eligible_default_csi? : client.eligible_custom_csi?
    eligible ? true : errors.add(:base, "Assessment cannot be added due to client's age.")
  end

  def index_of
    Assessment.order(:created_at).where(client_id: client_id).pluck(:id).index(id)
  end
end
