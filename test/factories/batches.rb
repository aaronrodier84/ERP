# == Schema Information
#
# Table name: batches
#
#  id           :integer          not null, primary key
#  product_id   :integer
#  quantity     :integer
#  notes        :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  completed_on :date
#  zone_id      :integer
#

FactoryGirl.define do
  factory :batch do
    quantity 20
    user_ids { [create(:user).id] }

    trait :with_product do
      product
    end

    trait :with_zone do
      zone
    end
  end
end
