# == Schema Information
#
# Table name: fba_allocations
#
#  id               :integer          not null, primary key
#  fba_warehouse_id :integer          not null
#  product_id       :integer          not null
#  quantity         :integer          not null
#

# This is a join saying how many product items should be shipped to an FBA warehouse.
class FbaAllocation < ActiveRecord::Base
  belongs_to :fba_warehouse
  belongs_to :product

  validates :quantity, presence: true, numericality: {greater_than_or_equal_to: 0}
end
