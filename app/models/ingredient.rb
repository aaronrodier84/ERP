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

class Ingredient < ActiveRecord::Base
  belongs_to :material
  belongs_to :product

  validates :product_id, presence: true
  validates :material_id, presence: true, uniqueness: {scope: :product_id, message: "is a duplicate" }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  default_scope -> { order(:id) }
  scope :for_zone,   ->(zone) { joins(:material => :zone).where('zones.id' => zone.id) }
  scope :up_to_zone, ->(zone) { joins(:material => :zone).where('zones.production_order <= ?', zone.production_order) }
  
  def material_name
    material&.name
  end

  def material_unit
    material&.unit
  end

  def material_zone
    material&.zone
  end

  def cost
    material.unit_price * quantity
  end

end
