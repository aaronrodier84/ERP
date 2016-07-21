# == Schema Information
#
# Table name: fba_warehouses
#
#  id                     :integer          not null, primary key
#  name                   :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

FactoryGirl.define do
  factory :fba_warehouse do
    sequence(:name) { |n| "test_#{n}"}
  end
end
