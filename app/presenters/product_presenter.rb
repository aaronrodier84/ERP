class ProductPresenter
  attr_reader :product
  attr_reader :product_inventory_presenter
  attr_reader :production_plan_presenter

  delegate :id, to: :product, prefix: true # product_id method

  delegate  :items_per_case, :reserved, :production_buffer_days, :days_of_cover,
            :has_make_zone?, :made_inventory_quantity,   :made_inventory_ingredients_cost,
            :has_pack_zone?, :packed_inventory_quantity, :packed_inventory_ingredients_cost,
            :has_ship_zone?, :has_zone?,
            :packed_inventory_quantity_in_days,
            :inbound_shipped, :fulfillable,
            :amazon_coverage_ratio, :total_amazon_inventory,
            :to_allocate_case_quantity, :to_allocate_item_quantity,
            :list_price_amount, :selling_price_amount,
            to: :product

  delegate :made_plus_packed_inventory_total, :made_plus_packed_cost_total,
           :fba_total, :fba_cost_total, :days_of_cover_hint,
           :inbound_shipped_cost_total, :fulfillable_cost_total,
           to: :product_inventory_presenter

  delegate :total_demand, :make_demand, :pack_demand, :ship_demand, :zone_demand,
           :to_cover_in_zone, :to_make, :to_pack,
           :to_ship, :to_ship_in_days, :to_ship_in_cases,
           :to_ship_case_excess, :to_ship_case_excess_percent,
           :zone_demand_provisioned?,
           to: :production_plan_presenter

  def initialize(product)
    @product = product
    @product_inventory_presenter = ProductInventoryPresenter.new(product)
    @production_plan_presenter = ProductionPlanPresenter.new(product)
  end

  def optimal_title
    return product.internal_title unless product.internal_title.blank? 
    return product.title unless product.title.blank?
    return "Untitled"
  end

  def ingredient_presenters_for_zone(zone)
    product.ingredients.for_zone(zone).map { |ing| IngredientPresenter.new(ing) }
  end

  def product_size
    product.size
  end

  def product_inventories
    @product_inventories ||= @product.available_inventories.for_visible_zones_only.ordered_by_zone.includes(:zone)
  end

  def amazon_coverage_ratio_limited
    [100, product.amazon_coverage_ratio].min
  end

  def fba_allocations_json
    ProductFbaAllocationPlan.new(product, product.to_allocate_item_quantity).generate_json
  end
end
