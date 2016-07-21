module UsersHelper
  def highlight_helper(user, current_user)
    'highlight' if user == current_user
  end

  def user_list(users)
    users.map(&:nickname).join(", ")
  end
end
