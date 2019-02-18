class Client < ActiveRecord::Base
  extend FriendlyId
  include ActionView::Helpers::TextHelper

  attr_reader :assessments_count
  attr_accessor :assessment_id
  attr_accessor :organization, :case_type

  friendly_id :slug, use: :slugged

  CLIENT_STATUSES = ['Accepted', 'Active', 'Exited', 'Referred'].freeze

  CLIENT_ACTIVE_STATUS = ['Active EC', 'Active FC', 'Active KC'].freeze
  ABLE_STATES = %w(Accepted Rejected Discharged).freeze
  CLIENT_FORM_ONE = %w(age code commune current_address date_of_birth district family_name local_family_name gender given_name local_given_name house_number current_province
    slug street_number village ngo gov_city gov_district gov_commune gov_village_code gov_client_code gov_interview_village gov_interview_commune gov_interview_district
    gov_interview_city gov_caseworker_name gov_caseworker_phone gov_carer_name gov_carer_relationship gov_carer_home gov_carer_street gov_carer_village gov_carer_commune
    gov_carer_district gov_carer_city gov_carer_phone)

  EXIT_STATUSES = CLIENT_STATUSES.select { |status| status if status.include?('Exited') || status.include?('Independent - Monitored')  }

  delegate :name, to: :township, prefix: true, allow_nil: true
  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :birth_province, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true
  delegate :name, to: :subdistrict, prefix: true, allow_nil: true
  delegate :name, to: :state, prefix: true, allow_nil: true
  delegate :name_kh, to: :commune, prefix: true, allow_nil: true
  delegate :name_kh, to: :village, prefix: true, allow_nil: true

  belongs_to :province,         counter_cache: true
  belongs_to :birth_province,   class_name: 'Province', foreign_key: 'birth_province_id', counter_cache: true
  belongs_to :district
  belongs_to :subdistrict
  belongs_to :state

  has_many :users, through: :case_worker_clients
  has_many :cases,          dependent: :destroy
  has_many :case_notes,     dependent: :destroy
  has_many :assessments,    dependent: :destroy
  has_many :client_enrollments, dependent: :destroy
  has_many :program_streams, through: :client_enrollments
  has_many :referrals, dependent: :destroy

  scope :live_with_like,              ->(value) { where('clients.live_with iLIKE ?', "%#{value}%") }
  scope :current_address_like,        ->(value) { where('clients.current_address iLIKE ?', "%#{value}%") }
  scope :house_number_like,           ->(value) { where('clients.house_number iLike ?', "%#{value}%") }
  scope :street_number_like,          ->(value) { where('clients.street_number iLike ?', "%#{value}%") }
  scope :village_like,                ->(value) { where('clients.village iLike ?', "%#{value}%") }
  scope :commune_like,                ->(value) { where('clients.commune iLike ?', "%#{value}%") }
  scope :district_like,               ->(value) { where('clients.district iLike ?', "%#{value}%") }
  scope :school_name_like,            ->(value) { where('clients.school_name iLIKE ?', "%#{value}%") }
  scope :referral_phone_like,         ->(value) { where('clients.referral_phone iLIKE ?', "%#{value}%") }
  scope :info_like,                   ->(value) { where('clients.relevant_referral_information iLIKE ?', "%#{value}%") }
  scope :slug_like,                   ->(value) { where('clients.slug iLIKE ?', "%#{value}%") }
  scope :kid_id_like,                 ->(value) { where('clients.kid_id iLIKE ?', "%#{value}%") }
  scope :start_with_code,             ->(value) { where('clients.code iLIKE ?', "#{value}%") }
  scope :find_by_family_id,           ->(value) { joins(cases: :family).where('families.id = ?', value).uniq }
  scope :status_like,                 ->        { CLIENT_STATUSES }
  scope :is_received_by,              ->        { joins(:received_by).pluck("CONCAT(users.first_name, ' ' , users.last_name)", 'users.id').uniq }
  scope :referral_source_is,          ->        { joins(:referral_source).pluck('referral_sources.name', 'referral_sources.id').uniq }
  scope :is_followed_up_by,           ->        { joins(:followed_up_by).pluck("CONCAT(users.first_name, ' ' , users.last_name)", 'users.id').uniq }
  scope :province_is,                 ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :accepted,                    ->        { where(state: 'accepted') }
  scope :rejected,                    ->        { where(state: 'rejected') }
  scope :male,                        ->        { where(gender: 'male') }
  scope :female,                      ->        { where(gender: 'female') }
  scope :active_ec,                   ->        { where(status: 'Active EC') }
  scope :active_kc,                   ->        { where(status: 'Active KC') }
  scope :active_fc,                   ->        { where(status: 'Active FC') }
  scope :without_assessments,         ->        { includes(:assessments).where(assessments:         { client_id: nil }) }
  scope :able,                        ->        { where(able_state: ABLE_STATES[0]) }
  scope :all_active_types,            ->        { where(status: CLIENT_ACTIVE_STATUS) }
  scope :of_case_worker,              -> (user_id) { joins(:case_worker_clients).where(case_worker_clients: { user_id: user_id }) }

  def self.filter(options)
    query = all
    query = query.where("gender = ?", "#{options[:gender]}")                      if options[:gender].present?
    query = query.where("status = ?", "#{options[:status]}")                      if options[:status].present?
    # query = option_filter(query, options[:case_workers])                          if options[:case_workers].present?

    query
  end

  # def self.option_filter(clients, case_workers)
  #   current_org_short_name = Organization.current.short_name
  #   case_worker_ids = case_workers.map{|v| v.gsub( /#{current_org_short_name}_/, '')}
  #   client_ids = joins(:users).where(users: { id: case_worker_ids }).ids.uniq
  #   clients = clients.where(id: client_ids)
  # end

  def reject?
    state_changed? && state == 'rejected'
  end

  # def exit_ngo?
  #   EXIT_STATUSES.include?(status)
  # end

  # def self.age_between(min_age, max_age)
  #   min = (min_age * 12).to_i.months.ago.to_date
  #   max = (max_age * 12).to_i.months.ago.to_date
  #   where(date_of_birth: max..min)
  # end


  # def self.next_assessment_candidates
  #   Assessment.where('client IN (?) AND ', self)
  # end

  # def next_assessment_date
  #   return Date.today if assessments.count.zero?
  #   (assessments.latest_record.created_at + 6.months).to_date
  # end

  # def next_appointment_date
  #   return Date.today if assessments.count.zero?

  #   last_assessment  = assessments.most_recents.first
  #   last_case_note   = case_notes.most_recents.first
  #   next_appointment = [last_assessment, last_case_note].compact.sort { |a, b| b.try(:created_at) <=> a.try(:created_at) }.first

  #   next_appointment.created_at + 1.month
  # end

  # def can_create_assessment?
  #   Date.today >= next_assessment_date
  # end

  # def self.able_managed_by(user)
  #   where('able_state = ? or user_id = ?', ABLE_STATES[0], user.id)
  # end

  # def self.in_any_able_states_managed_by(user)
  #   joins(:case_worker_clients).where('able_state IN(?) OR case_worker_clients.user_id = ?', ABLE_STATES, user.id)
  # end

  # def self.managed_by(user, status)
  #   where('status = ? or user_id = ?', status, user.id)
  # end

  # def reset_tasks_of_users
  #   return unless tasks.any? && user_ids != tasks.pluck(:user_id)
  #   tasks.each do |task|
  #     users.map { |user| CaseWorkerTask.find_or_create_by(task_id: task.id, user_id: user.id) }
  #   end
  #   CaseWorkerTask.where(task_id: tasks.ids).where.not(user_id: user_ids).destroy_all
  # end

  # def has_no_ec_or_any_cases?
  #   cases.emergencies.blank? || cases.active.blank?
  # end

  # def has_no_active_kc_and_fc?
  #   cases.kinships.active.blank? && cases.fosters.active.blank?
  # end

  # def has_kc_and_fc?
  #   cases.kinships.present? && cases.fosters.present?
  # end

  # def has_no_kc_and_fc?
  #   !has_kc_or_fc?
  # end

  # def has_exited_kc_and_fc?
  #   cases.latest_kinship.exited && cases.latest_foster.exited
  # end

  # def has_kc_or_fc?
  #   cases.kinships.present? || cases.fosters.present?
  # end

  # def has_no_latest_kc_and_fc?
  #   !latest_case
  # end

  # def has_any_quarterly_reports?
  #   (cases.active.latest_kinship.present? && cases.latest_kinship.quarterly_reports.any?) || (cases.active.latest_foster.present? && cases.latest_foster.quarterly_reports.any?)
  # end

  # def latest_case
  #   cases.active.latest_kinship.presence || cases.active.latest_foster.presence
  # end
  def display_age
    pluralize(self.age_as_years, 'year') + ' ' + pluralize(self.age_extra_months, 'month') if date_of_birth.present?
  end

  def age_as_years(date = Date.today)
    return if date_of_birth.nil?
    ((date - date_of_birth) / 365).to_i
  end

  def age_filter_query(dob)
    return if dob.nil?
    ((Date.today - dob) / 365).to_i
  end

  def age_extra_months(date = Date.today)
    ((date - date_of_birth) % 365 / 31).to_i
  end

  # def able?
  #   able_state == ABLE_STATES[0]
  # end

  # def rejected?
  #   able_state == ABLE_STATES[1]
  # end

  # def discharged?
  #   able_state == ABLE_STATES[2]
  # end

  # def active_kc?
  #   status == 'Active KC'
  # end

  # def active_fc?
  #   status == 'Active FC'
  # end

  # def active_ec?
  #   status == 'Active EC'
  # end

  # def active_case?
  #   active_ec? || active_fc? || active_kc?
  # end

  # def set_slug_as_alias
  #   paper_trail.without_versioning { |obj| obj.update_attributes(slug: "#{Organization.current.try(:short_name)}-#{id}") }
  # end

  # def set_able_status
  #   update(able_state: ABLE_STATES[0]) if AbleScreeningQuestion.has_alert_manager?(self) && answers.include_yes?
  # end

  # def time_in_care
  #   if cases.any?
  #     if cases.active.any?
  #       (active_day_care / 365).round(1)
  #     else
  #       (inactive_day_care / 365).round(1)
  #     end
  #   else
  #     nil
  #   end
  # end

  # def self.exit_in_week(number_of_day)
  #   date = number_of_day.day.ago.to_date
  #   active_ec.joins(:cases).where(cases: { case_type: 'EC', start_date: date })
  # end

  # def active_day_care
  #   active_cases      = cases.active.order(:created_at)
  #   first_active_case = active_cases.first

  #   start_date        = first_active_case.start_date.to_date
  #   current_date      = Date.today.to_date
  #   (current_date - start_date).to_f
  # end

  # def inactive_day_care
  #   inactive_cases     = cases.inactive.order(:updated_at)
  #   last_inactive_case = inactive_cases.last
  #   end_date           = last_inactive_case.exit_date.to_date

  #   first_case         = cases.inactive.order(:created_at).first
  #   start_date         = first_case.start_date.to_date

  #   (end_date - start_date).to_f
  # end


  # def self.ec_reminder_in(day)
  #   Organization.all.each do |org|
  #     Organization.switch_to org.short_name
  #     managers = User.ec_managers.pluck(:email).join(', ')
  #     admins   = User.admins.pluck(:email).join(', ')
  #     clients = active_ec.select { |client| client.active_day_care == day }

  #     if clients.present?
  #       ManagerMailer.remind_of_client(clients, day: day, manager: managers).deliver_now if managers.present?
  #       AdminMailer.remind_of_client(clients, day: day, admin: admins).deliver_now if admins.present?
  #     end
  #   end
  # end

  # def populate_needs
  #   Need.all.each do |need|
  #     client_needs.build(need: need)
  #   end
  # end

  # def populate_problems
  #   Problem.all.each do |problem|
  #     client_problems.build(problem: problem)
  #   end
  # end

  # private

  # def create_client_history
  #   ClientHistory.initial(self)
  # end
end
