# == Schema Information
#
# Table name: user_zones
#
#  id      :integer          not null, primary key
#  user_id :integer
#  zone_id :integer
#

class UserZone < ActiveRecord::Base
  belongs_to :user
  belongs_to :zone
end
