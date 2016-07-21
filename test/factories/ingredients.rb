# == Schema Information
#
# Table name: ingredients
#
#  id          :integer          not null, primary key
#  material_id :integer          not null
#  product_id  :integer          not null
#  quantity    :integer          default(1), not null
#  created_at  :datetime
#  updated_at  :datetime
#
# Foreign Keys
#
#  fk_rails_7ab80c2b55  (material_id => materials.id)
#  fk_rails_db974bf3ef  (product_id => products.id)
#

FactoryGirl.define do
  factory :ingredient do
    material
    product 
    quantity 1
  end
end
