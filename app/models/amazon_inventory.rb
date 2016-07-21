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

class AmazonInventory < ActiveRecord::Base
  belongs_to :product
  has_many :amazon_inventory_histories

  def total_amazon_inventory
    inbound_shipped + fulfillable
  end

  def days_of_cover
    ProductAmount.new(total_amazon_inventory).days(reserved)
  end

  def days_to_cover
    days = product.production_buffer_days - days_of_cover
    [0, days].max
  end

  def coverage_ratio
    buffer = product.production_buffer_days
    return 100 if buffer.zero?
    (100 * days_of_cover / buffer).to_i
  end
end
