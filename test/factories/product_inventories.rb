# == Schema Information
#
# Table name: product_inventories
#
#  id         :integer          not null, primary key
#  quantity   :integer          default(0)
#  product_id :integer
#  zone_id    :integer
#

FactoryGirl.define do
  factory :product_inventory do
    quantity 10
  end
end
