class UsersController < AdminController

  before_action :find_user, only: [:show, :edit, :update, :destroy]

  def index
    respond_to do |f|
      f.html do
        users        = list_users_filter
        @users_count = users.count
        @users       = Kaminari.paginate_array(users).page(params[:page]).per(20)
        # authorize @users
      end
      f.json { render json: UsersDatatable.new(view_context)}
    end
  end

  def new
    @user = User.new(enable_research_log_in: true)
    # authorize @user
  end

  def create
    @user = User.new(user_params)
    # authorize @user
    if @user.save
      redirect_to @user, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    # authorize @user
  end

  def edit
    # authorize @user
  end

  def update
    # authorize @user
    if @user.update_attributes(user_params)
      redirect_to @user, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    # authorize @user
    if @user.destroy
      redirect_to users_url, notice: t('.successfully_deleted')
    else
      redirect_to users_url, alert: t('.alert')
    end
  end

  def disable
    @user = User.find(params[:user_id])
    redirect_to users_path, notice: t('.successfully_disable') if @user.update_attributes(disable: !@user.disable)
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :start_date, :job_title, :mobile, :date_of_birth, :email, :roles, :password, :password_confirmation, :enable_research_log_in, :enable_gov_log_in)
  end

  def find_user
    @user = User.find(params[:id])
  end

  def users_ordered(users)
    users = users.sort_by(&:name)
    column = params[:order]
    return users unless column
    if %w(age_as_years id_poor).include?(column)
      ordered = users.sort_by{ |p| p.send(column).to_i }
    elsif column == 'slug'
      ordered = users.sort_by{ |p| [p.send(column).split('-').first, p.send(column)[/\d+/].to_i] }
    else
      ordered = users.sort_by{ |p| p.send(column).to_s.downcase }
    end
    column.present? && params[:descending] == 'true' ? ordered.reverse : ordered
  end

  def fetch_users
    users = User.all.reload
    users.flatten
  end

  def list_users_filter
    users = users_ordered(fetch_users)
  end
end
