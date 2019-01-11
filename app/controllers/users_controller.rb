class UsersController < AdminController
  before_action :find_user, only: [:show, :edit, :update, :destroy]

  def index
    @user_grid = UsersGrid.new(params[:users_grid])
    respond_to do |f|
      f.html do
        @results = @user_grid.assets.size
        @user_grid.scope { |scope| scope.page(params[:page]).per(10) }
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to @user, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
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
    params.require(:user).permit(:first_name, :last_name, :start_date, :job_title, :mobile, :date_of_birth, :email, :password, :password_confirmation)
  end

  def find_user
    @user = User.find(params[:id])
  end
end
