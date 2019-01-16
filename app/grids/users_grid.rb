class UsersGrid
  include Datagrid

  scope do
    User.only_from_oscar_research.order(:first_name, :last_name)
  end

  filter(:first_name, :string, header: -> { I18n.t('datagrid.columns.users.first_name') }) do |value, scope|
    scope.first_name_like(value)
  end

  filter(:last_name, :string, header: -> { I18n.t('datagrid.columns.users.last_name') }) do |value, scope|
    scope.last_name_like(value)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.users.id') })

  filter(:mobile, :string,  header: -> { I18n.t('datagrid.columns.users.mobile') }) do |value, scope|
    scope.mobile_like(value)
  end

  filter(:email, :string,  header: -> { I18n.t('datagrid.columns.users.email') }) do |value, scope|
    scope.email_like(value)
  end

  filter(:date_of_birth, :date, range: true, header: -> { I18n.t('datagrid.columns.users.date_of_birth') })

  column(:id, header: -> { I18n.t('datagrid.columns.users.id') })

  column(:name, html: true, order: 'LOWER(users.first_name), LOWER(users.last_name)',  header: -> { I18n.t('datagrid.columns.users.name') }) do |object|
    link_to "#{object.first_name} #{object.last_name}", user_path(object)
  end

  column(:first_name, header: -> { I18n.t('datagrid.columns.users.first_name') }, html: false)
  column(:last_name, header: -> { I18n.t('datagrid.columns.users.last_name') }, html: false)

  column(:date_of_birth, header: -> { I18n.t('datagrid.columns.users.date_of_birth') })

  column(:mobile, header: -> { I18n.t('datagrid.columns.users.mobile') })

  column(:email, header: -> { I18n.t('datagrid.columns.users.email') }) do |object|
    format(object.email) do |object_email|
      mail_to object_email
    end
  end

  column(:job_title, header: -> { I18n.t('datagrid.columns.users.job_title') })

  column(:manage, header: -> { I18n.t('datagrid.columns.users.manage') }, html: true, class: 'text-center') do |object|
    render partial: 'users/actions', locals: { object: object }
  end
end
