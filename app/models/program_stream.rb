class ProgramStream < ActiveRecord::Base
  has_many   :client_enrollments, dependent: :restrict_with_error
  has_many   :clients, through: :client_enrollments
  has_many   :program_stream_services, dependent: :destroy
  has_many   :services, through: :program_stream_services

  has_paper_trail

  validates :name, presence: true
  validates :name, uniqueness: true

  validate  :rules_edition, :program_edition, on: :update, if: Proc.new { |p| p.client_enrollments.active.any? }

  scope  :ordered,        ->         { order('lower(name) ASC') }
  scope  :complete,       ->         { where(completed: true) }
  scope  :ordered_by,     ->(column) { order(column) }
  scope  :filter,         ->(value)  { where(id: value) }
  scope  :name_like,      ->(value)  { where(name: value) }
  scope  :by_name,        ->(value)  { where('name iLIKE ?', "%#{value.squish}%") }

  def name=(name)
    write_attribute(:name, name.try(:strip))
  end

  def self.inactive_enrollments(client)
    joins(:client_enrollments).where("client_id = ? AND client_enrollments.created_at = (SELECT MAX(client_enrollments.created_at) FROM client_enrollments WHERE client_enrollments.program_stream_id = program_streams.id AND client_enrollments.client_id = #{client.id}) AND client_enrollments.status = 'Exited' ", client.id).ordered
  end

  def self.active_enrollments(client)
    joins(:client_enrollments).where("client_id = ? AND client_enrollments.created_at = (SELECT MAX(client_enrollments.created_at) FROM client_enrollments WHERE client_enrollments.program_stream_id = program_streams.id AND client_enrollments.client_id = #{client.id}) AND client_enrollments.status = 'Active' ", client.id).ordered
  end

  def self.without_status_by(client)
    ids = includes(:client_enrollments).where(client_enrollments: { client_id: client.id }).order('client_enrollments.status ASC', :name).uniq.collect(&:id)
    where.not(id: ids).ordered
  end

  def program_edition
    clients.each do |client|
      program_stream_ids = client.client_enrollments.active.pluck(:program_stream_id).to_set
      can_edit_program = false
      if program_exclusive_changed? && program_exclusive.any? && program_exclusive.to_set.subset?(program_stream_ids)
        self.program_exclusive = program_exclusive_was
        error_message = "#{I18n.t('program_exclusive_has_been_modified')}"
        errors.add(:program_exclusive, error_message)
        can_edit_program = true
      end

      if mutual_dependence_changed? && mutual_dependence.any? && !(mutual_dependence.to_set.subset?(program_stream_ids))
        self.mutual_dependence = mutual_dependence_was
        error_message = "#{I18n.t('mutual_dependence_has_been_modified')}"
        errors.add(:mutual_dependence, error_message)
        can_edit_program = true
      end

      break if can_edit_program
    end
  end

  def last_enrollment
    client_enrollments.last
  end

  def number_available_for_client
    quantity - client_enrollments.active.size
  end

  def enroll?(client)
    enrollments = client_enrollments.enrollments_by(client).order(:created_at)
    (enrollments.present? && enrollments.first.status == 'Exited') || enrollments.empty?
  end

  def is_used?
    client_enrollments.active.present?
  end

  def has_mutual_dependence?
    mutual_dependence.any?
  end

  def has_rule?
    rules.present?
  end

  private

  def get_client_ids(rules)
    active_client_ids = client_enrollments.active.pluck(:client_id).uniq
    active_clients    = Client.where(id: active_client_ids)
    clients           = AdvancedSearches::ClientAdvancedSearch.new(rules, active_clients)
    clients.filter.ids
  end

  def unchanged_rules?(current_ids, previous_ids)
    if current_ids.any? && previous_ids.any?
      previous_ids.subset?(current_ids)
    else
      return false
    end
  end

  def enrollment_errors_message
    properties = client_enrollments.pluck(:properties).select(&:present?)
    error_fields(properties, enrollment_change).join(', ')
  end
end
