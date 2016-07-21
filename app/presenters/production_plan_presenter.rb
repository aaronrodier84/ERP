# frozen_string_literal: true

# Product Details - Production Forecast section presenter.
class ProductionPlanPresenter
  attr_reader :product
  attr_reader :production_plan

  delegate :total_demand, :make_demand, :pack_demand, :ship_demand, :zone_demand,
           :to_cover_in_zone, :to_make, :to_pack,
           :to_ship, :to_ship_in_cases,
           :zone_demand_provisioned?,
           to: :production_plan

  def initialize(product)
    @product = product
    @production_plan = ProductionPlan.new(product)
  end

  def to_ship_in_days
    ProductAmount.new(to_ship).days(product.reserved)
  end

  def to_ship_case_excess
    ProductAmount.new(to_ship).case_excess(product.items_per_case)
  end

  def to_ship_case_excess_percent
    ProductAmount.new(to_ship).case_excess_percent(product.items_per_case)
  end
end
