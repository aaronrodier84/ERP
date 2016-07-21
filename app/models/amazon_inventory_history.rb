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

class AmazonInventoryHistory < ActiveRecord::Base
  belongs_to :amazon_inventory

  def self.smooth_reserved(new_value)
    reserved_values = last(2).map(&:reserved) << new_value.to_f
    reserved_values.sum / reserved_values.size.to_f
  end
end
