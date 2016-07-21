# frozen_string_literal: true

def current_user
  @user
end

# This method is for controller tests
def quick_login_user
  @user ||= create :user
  sign_in @user
end

# This method is for controller tests
def quick_login_admin
  @user ||= create :admin
  sign_in @user
end

# This method is for integration tests
# Note: Newer versions of Devise have sign_in method version compatible with integration tests.
# So there would be no need to pass through all these steps.
def login_user(add_to_all_zones=true)
  password = "11111111"
  @user ||= FactoryGirl.create(:user, email: "user@example.com", password: password, password_confirmation: password)

  add_user_to_all_zones(@user) if add_to_all_zones

  visit root_path
  fill_in "user_email", with: @user.email
  fill_in "user_password", with: password
  click_on "Log in"
  assert page.has_content? "Signed in successfully"
end
