class UserPolicy < ApplicationPolicy

  def edit?
    user.admin?
  end

  def new?
    user.admin?
  end

  def index?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  alias show? index?

  alias create? new?

  alias update? edit?
end
