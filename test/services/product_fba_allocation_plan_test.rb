# frozen_string_literal: true
require 'test_helper'

class ProductFbaAllocationPlanTest < ActiveSupport::TestCase
  let(:product) { create :product }
  let(:pack_zone) { create :zone, :pack }
  let(:fba_warehouse1) { create :fba_warehouse, name: 'PHX7' }
  let(:fba_warehouse2) { create :fba_warehouse, name: 'RIC1' }
  let(:fba_allocation1) { create :fba_allocation, fba_warehouse: fba_warehouse1, product: product, quantity: 30_000 }
  let(:fba_allocation2) { create :fba_allocation, fba_warehouse: fba_warehouse2, product: product, quantity: 70_000 }

  describe '#generate_json' do
    it 'return correct fba allocations' do
      create :product_inventory, product: product, quantity: 5000, zone: pack_zone
      product.fba_allocations = [fba_allocation1, fba_allocation2]

      allocation_plan = described_class.new(product, 5000)
      allocations = allocation_plan.generate_json
      allocation_quantity_first = JSON.parse(allocations.first)["quantity"]
      allocation_quantity_second = JSON.parse(allocations.second)["quantity"]

      assert_equal 5000, allocation_quantity_first + allocation_quantity_second
    end

    it 'is empty if packed inventory quantity 0' do
      create :product_inventory, product: product, quantity: 0, zone: pack_zone
      allocation_plan = described_class.new(product, 5000)
      assert_equal [], allocation_plan.generate_json
    end
  end

  describe '#valid_against?' do
    it 'return true if valid' do
      create :product_inventory, product: product, quantity: 5000, zone: pack_zone
      product.fba_allocations = [fba_allocation1, fba_allocation2]
      allocation_plan = described_class.new(product, 5000)
      assert_equal true, allocation_plan.valid_against?(fba_warehouse1)
    end

    it 'return false if overflow' do
      create :product_inventory, product: product, quantity: 5000, zone: pack_zone
      product.fba_allocations = [fba_allocation1, fba_allocation2]
      allocation_plan = described_class.new(product, 20_000)
      assert_equal false, allocation_plan.valid_against?(fba_warehouse1)
    end

    it 'return false if pack inventory is zero' do
      create :product_inventory, product: product, quantity: 0, zone: pack_zone
      product.fba_allocations = [fba_allocation1, fba_allocation2]
      allocation_plan = described_class.new(product, 1000)
      assert_equal false, allocation_plan.valid_against?(fba_warehouse1)
    end
  end
end
