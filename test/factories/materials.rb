# == Schema Information
#
# Table name: materials
#
#  id                 :integer          not null, primary key
#  zone_id            :integer          not null
#  name               :string           not null
#  unit               :string
#  unit_price         :decimal(, )      default(0.0), not null
#  created_at         :datetime
#  updated_at         :datetime
#  inventory_quantity :integer          default(0), not null
#
# Foreign Keys
#
#  fk_rails_8c44ac1fea  (zone_id => zones.id)
#

FactoryGirl.define do
  factory :material do
    name 'Bottle'
    unit_price 1.99
    inventory_quantity 0
    zone 
  end
end
