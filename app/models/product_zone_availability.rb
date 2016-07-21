# == Schema Information
#
# Table name: product_zone_availabilities
#
#  id         :integer          not null, primary key
#  product_id :integer
#  zone_id    :integer
#

class ProductZoneAvailability < ActiveRecord::Base
  belongs_to :product, touch: true
  belongs_to :zone
end
