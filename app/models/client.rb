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

  delegate :name, to: :referral_source, prefix: true, allow_nil: true
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
  belongs_to :referral_source,  counter_cache: true
  belongs_to :carer

  has_many :users, through: :case_worker_clients
  has_many :cases,          dependent: :destroy
  has_many :case_notes,     dependent: :destroy
  has_many :assessments,    dependent: :destroy
  has_many :client_enrollments, dependent: :destroy
  has_many :program_streams, through: :client_enrollments
  has_many :custom_field_properties, as: :custom_formable, dependent: :destroy
  has_many :custom_fields, through: :custom_field_properties, as: :custom_formable
  has_many :client_quantitative_cases, dependent: :destroy
  has_many :quantitative_cases, through: :client_quantitative_cases
  has_many :exit_ngos, dependent: :destroy

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

  def self.sql_string_mapping(sql_string)
    sql_string.gsub(/basicfield_/, '').gsub('birth_province', 'bp')
              .gsub('current_province', 'cp').gsub('district', 'd')
              .gsub('gender', '%{ngo}.clients.gender')
              .gsub('status', '%{ngo}.clients.status')
              .gsub(/enrollment_count(.*?)\d+/, '(SELECT %{ngo}.clients.id FROM %{ngo}.clients LEFT OUTER JOIN %{ngo}.client_enrollments ON %{ngo}.client_enrollments.client_id = %{ngo}.clients.id GROUP BY %{ngo}.clients.id HAVING COUNT(client_enrollments) = 12)')
              .gsub('date_of_birth', 'EXTRACT(year FROM age(current_date, %{ngo}.clients.date_of_birth))')
  end

  def reject?
    state_changed? && state == 'rejected'
  end

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
end
