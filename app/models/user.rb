class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ROLES = ['admin', 'user'].freeze

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :roles, inclusion: { in: ROLES }

  before_create :set_created_from

  scope :only_from_oscar_research, -> { where(created_from: 'oscar_research') }

  ROLES.each do |role|
    define_method("#{role.parameterize.underscore}?") do
      roles == role
    end
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
