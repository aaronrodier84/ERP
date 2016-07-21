# == Schema Information
#
# Table name: fba_warehouses
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime
#  updated_at :datetime
#

# FbaWarehouse is a warehouse in Amazon.
# Amazon distributes products by FBA warehouses automatically, we do not manage this.
# All we do is ask Amazon API to distribute a certain amount of product;
# Then Amazon responds with how many items should go where. And we save this information.
class FbaWarehouse < ActiveRecord::Base
  has_many :fba_allocations
  has_many :products

  validates :name, presence: true
end
