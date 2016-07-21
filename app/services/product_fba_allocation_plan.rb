# frozen_string_literal: true

class ProductFbaAllocationPlan
  attr_reader :product, :quantity

  def initialize(product, quantity)
    @product = product
    @quantity = quantity
  end

  def valid_against?(warehouse)
    quantity_for(warehouse) <= product.packed_inventory_quantity
  end

  # result format: [{warehouse_id: 3, warehouse_name: 'ABC1', quantity: 3240}, {}, ...]
  def generate_json
    product.fba_warehouses.map do |warehouse|
      {
        warehouse_id: warehouse.id,
        warehouse_name: warehouse.name,
        quantity: quantity_for(warehouse)
      }.to_json
    end
  end

  protected

  def quantity_for(warehouse)
    allocation = product.fba_allocations.find_by fba_warehouse: warehouse
    (allocation.quantity * allocation_plan_coefficient).round
  end

  def allocation_plan_coefficient
    @previous_allocation_plan_qty ||= product.fba_allocations.sum(:quantity)
    quantity.to_f / @previous_allocation_plan_qty
  end
end
