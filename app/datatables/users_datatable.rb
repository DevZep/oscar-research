class UsersDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: users.total_count,
      aaData: data
    }
  end

private

  def data
    users.map do |user|
      [
        user.id,
        link_to(user.name, user),
        user.date_of_birth,
        user.mobile,
        user.email,
        user.job_title
      ]
    end
  end

  def users
    @users ||= fetch_users
  end

  def fetch_users
    users = User.order("#{sort_column} #{sort_direction}")
    users = users.page(page)
    if params[:sSearch].present?
      users = users.where("first_name like :search or last_name like :search or mobile like :search or email like :search", search: "%#{params[:sSearch]}%")
    end
    users
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id first_name date_of_birth mobile email job_title]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end