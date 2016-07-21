# == Schema Information
#
# Table name: amazon_inventory_histories
#
#  id                  :integer          not null, primary key
#  fulfillable         :integer
#  reserved            :integer
#  inbound_working     :integer
#  inbound_shipped     :integer
#  reported_at         :datetime
#  amazon_inventory_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

FactoryGirl.define do
  factory :amazon_inventory_history do
    fulfillable 20
    reserved 30
    inbound_working 30
    inbound_shipped 40
  end
end
