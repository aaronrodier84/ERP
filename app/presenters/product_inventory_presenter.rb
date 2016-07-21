# frozen_string_literal: true

# Product Details - Inventory section presenter.
class ProductInventoryPresenter
  attr_reader :product

  def initialize(product)
    @product = product
  end

  def made_plus_packed_inventory_total
    product.made_inventory_quantity + product.packed_inventory_quantity
  end

  def made_plus_packed_cost_total
    product.made_inventory_ingredients_cost + product.packed_inventory_ingredients_cost
  end

  def fba_total
    product.inbound_shipped + product.fulfillable
  end

  def inbound_shipped_cost_total
    ProductAmount.new(product.inbound_shipped).cost(product.selling_price_amount)
  end

  def fulfillable_cost_total
    ProductAmount.new(product.fulfillable).cost(product.selling_price_amount)
  end

  def fba_cost_total
    inbound_shipped_cost_total + fulfillable_cost_total
  end

  # rubocop:disable OutputSafety
  def days_of_cover_hint
    "= #{product.inbound_shipped + product.fulfillable} / #{product.reserved}".gsub(' ', '&nbsp;').html_safe
  end
  # rubocop:enable OutputSafety
end
