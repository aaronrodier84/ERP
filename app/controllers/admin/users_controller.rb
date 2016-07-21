class Admin::UsersController < ApplicationController

  def index
    active_users = User.active.ordered
    inactive_users = User.inactive.ordered
    render locals: { active_users: active_users, inactive_users: inactive_users }
  end

  def new
    user = User.new
    render locals: { user: user, zones: Zone.ordered }
  end

  def edit
    user = find_user
    render locals: { user: user, zones: Zone.ordered }
  end

  def update
    user = find_user
    result = actions[:update_user].call user, user_params
    if result.success?
      sign_in(user, bypass:true) if user_params.include?(:password)
      redirect_to admin_users_path, notice: "User successfully updated"
    else
			render 'edit', locals: { user: result.entity, zones: Zone.ordered }
    end
  end

  def create
    result = actions[:create_user].call user_params
    if result.success?
      user = result.entity
      redirect_to admin_users_path, notice: "User successfully created with password: #{user.password}"
    else
			render 'new', locals: { user: result.entity, zones: Zone.ordered }
    end
  end

  def destroy
    user = find_user
    actions[:destroy_user].call user
    redirect_to admin_users_path, notice: "User successfully deleted."
  end

  def actions
    { create_user: Users::CreateUser.new,
      update_user: Users::UpdateUser.new,
      destroy_user: Users::DestroyUser.new}
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :is_active,
			:password,
			:password_confirmation,
      :zone_ids => []
    )
  end

  def find_user
    User.find(params[:id])
  end
end
