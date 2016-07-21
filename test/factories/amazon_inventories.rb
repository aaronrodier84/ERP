# == Schema Information
#
# Table name: amazon_inventories
#
#  id              :integer          not null, primary key
#  fulfillable     :integer          default(0)
#  reserved        :integer          default(0)
#  inbound_working :integer          default(0)
#  inbound_shipped :integer          default(0)
#  product_id      :integer
#

FactoryGirl.define do
  factory :amazon_inventory do
    fulfillable 10
    reserved 20
    inbound_working 30
    inbound_shipped 40
  end
end
