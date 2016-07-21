# frozen_string_literal: true
class ProductionPlan
  attr_reader :product

  def initialize(product)
    @product = product
    @zone_workflow = ZoneWorkflow.new(product.zones)
  end

  def total_demand
    product.reserved * product.production_buffer_days
  end

  def zone_demand(zone)
    product_zones = product.zones

    return 0 unless product_zones.include?(zone)
    return ship_demand if zone.ship?

    current_zone_inventory = product.zone_inventory_quantity(zone)

    next_zone = @zone_workflow.next_zone(zone)
    return 0 unless next_zone # weird product that e.g. has :pack as the last zone
    next_zone_demand = zone_demand(next_zone)

    [0, next_zone_demand - current_zone_inventory].max
  end

  def make_demand
    zone_demand(Zone.make_zone)
  end

  def pack_demand
    zone_demand(Zone.pack_zone)
  end

  def ship_demand
    amazon_inventory = product.total_amazon_inventory
    if amazon_inventory.zero?
      [total_demand, product.items_per_case].max # ship at least one case
    else
      [0, total_demand - amazon_inventory].max
    end
  end

  def zone_provision(zone)
    prev_zone = @zone_workflow.previous_zone(zone)
    return Float::INFINITY unless prev_zone # first zone is provisioned
    product.zone_inventory_quantity(prev_zone)
  end

  def zone_demand_provisioned?(zone)
    zone_demand(zone) <= zone_provision(zone)
  end

  def to_cover_in_zone(zone)
    [zone_demand(zone), zone_provision(zone)].min
  end

  def to_make
    to_cover_in_zone(Zone.make_zone)
  end

  def to_pack
    to_cover_in_zone(Zone.pack_zone)
  end

  def to_ship
    to_cover_in_zone(Zone.ship_zone)
  end

  def to_ship_in_cases
    # More logic to go here
    ProductAmount.new(to_ship).cases(product.items_per_case)
  end
end
