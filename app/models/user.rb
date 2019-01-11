class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_save :set_created_from

  validates :email, presence: true, uniqueness: { case_sensitive: false }

  scope :only_from_oscar_research, -> { where(created_from: 'oscar_research') }

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
