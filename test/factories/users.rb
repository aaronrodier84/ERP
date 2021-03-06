# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_active              :boolean          default(TRUE)
#  first_name             :string
#  last_name              :string
#  admin                  :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "just.email_#{n}@email.com"}
    password 'password'
    first_name 'John'
    last_name 'Hanckok'

    factory :admin do
      admin true
    end

    trait :with_zone do
      zone
    end
  end
end
