# == Schema Information
#
# Table name: product_inventories
#
#  id         :integer          not null, primary key
#  quantity   :integer          default(0)
#  product_id :integer
#  zone_id    :integer
#

class ProductInventory < ActiveRecord::Base
  belongs_to :product, touch: true
  belongs_to :zone

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  scope :ordered_by_zone, -> { joins(:zone).merge(Zone.ordered) }
  scope :for_visible_zones_only, -> { where(zone: Zone.visible.to_a) }

  def name
    "#{zone.name.capitalize} inventory"
  end

  def debit(amount)
    raise ArgumentError.new('Only positive amount is allowed') unless amount > 0
    with_lock do
      self.quantity -= amount
      save!
    end
  end

  def credit(amount)
    raise ArgumentError.new('Only positive amount is allowed') unless amount > 0
    with_lock do
      self.quantity += amount
      save!
    end
  end

  concerning :Ingredients do
    # For pack zone, includes pack zone ingredients only.
    def zone_ingredients_cost
      quantity * product.zone_ingredients_cost(zone)
    end

    # For pack zone, includes pack and all previous zones' (make) ingredients.
    def total_spent_ingredients_cost
      quantity * product.cumulative_zone_ingredients_cost(zone)
    end
  end
end
