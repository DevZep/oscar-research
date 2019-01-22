class ClientEnrollment < ActiveRecord::Base
  belongs_to :client
  belongs_to :program_stream

  alias_attribute :new_date, :enrollment_date

  validates :enrollment_date, presence: true
  validate :enrollment_date_value, if: 'enrollment_date.present?'

  has_paper_trail

  scope :enrollments_by,              ->(client)         { where(client_id: client) }
  scope :find_by_program_stream_id,   ->(value)          { where(program_stream_id: value) }
  scope :active,                      ->                 { where(status: 'Active') }
  scope :inactive,                    ->                 { where(status: 'Exited') }

  delegate :name, to: :program_stream, prefix: true, allow_nil: true

  def active?
    status == 'Active'
  end

  def short_enrollment_date
    enrollment_date.end_of_month.strftime '%b-%y'
  end
end
