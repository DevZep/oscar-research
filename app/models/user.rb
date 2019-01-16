class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ROLES = ['admin', 'user'].freeze

  has_many :case_worker_clients, dependent: :restrict_with_error
  has_many :clients, through: :case_worker_clients
  has_many :advanced_searches, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :roles, inclusion: { in: ROLES }

  before_create :set_created_from

  scope :only_from_oscar_research, -> { where(created_from: 'oscar_research') }
  scope :first_name_like, ->(value) { where('first_name iLIKE ?', "%#{value}%") }
  scope :last_name_like,  ->(value) { where('last_name iLIKE ?', "%#{value}%") }
  scope :mobile_like,     ->(value) { where('mobile iLIKE ?', "%#{value}%") }
  scope :email_like,      ->(value) { where('email iLIKE  ?', "%#{value}%") }
  scope :job_title_are,   ->        { where.not(job_title: '').pluck(:job_title).uniq }
  scope :province_are,    ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :has_clients,     ->        { joins(:clients).without_json_fields.uniq }

  ROLES.each do |role|
    define_method("#{role.parameterize.underscore}?") do
      roles == role
    end
  end

  def active_for_authentication?
    super && created_from == 'oscar_research'
  end

  def name
    full_name = "#{first_name} #{last_name}"
    full_name.present? ? full_name : 'Unknown'
  end

  private

    def set_created_from
      self.created_from = 'oscar_research'
    end

end
