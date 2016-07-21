# == Schema Information
#
# Table name: fba_allocations
#
#  id                     :integer          not null, primary key
#  product_id             :integer          not null
#  fba_warehouse_id       :integer          not null
#  quantity               :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

FactoryGirl.define do
  factory :fba_allocation do
    quantity 500
  end
end
