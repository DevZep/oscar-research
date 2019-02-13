class Assessment < ActiveRecord::Base
  belongs_to :client, counter_cache: true

  has_many :assessment_domains, dependent: :destroy
  has_many :domains,            through:   :assessment_domains

  scope :defaults, -> { where(default: true) }
  scope :most_recents, -> { order(created_at: :desc) }

  def basic_info
    "#{created_at.to_date} => #{assessment_domains_score}"
  end

  def self.latest_record
    most_recents.first
  end

  def assessment_domains_score
    domains.pluck(:name, :score).map { |item| item.join(': ') }.join(', ')
  end
end
