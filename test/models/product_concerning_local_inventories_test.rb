# frozen_string_literal: true
require 'test_helper'

class ProductConcerningLocalInventoriesTest < ActiveSupport::TestCase
  let(:product) { create :product }

  describe "#make_product_inventory_record" do
    let(:make_zone) { create :zone, :make }

    it "returns associated ProductInventory record for Pack zone" do
      inventory = ProductInventory.create(product: product, zone: make_zone)
      assert_equal inventory, product.make_product_inventory_record
    end
  end

  describe "#pack_product_inventory_record" do
    let(:pack_zone) { create :zone, :pack }

    it "returns associated ProductInventory record for Pack zone" do
      inventory = ProductInventory.create(product: product, zone: pack_zone)
      assert_equal inventory, product.pack_product_inventory_record
    end
  end

  describe "#zone_inventory_quantity" do
    let(:zone) { create :zone }

    it "delegates call to product_inventory record" do
      create :product_inventory, product: product, zone: zone, quantity: 112
      assert_equal 112, product.zone_inventory_quantity(zone)
    end

    describe "when product_inventory record is not found" do
      it "returns 0" do
        assert_equal 0, product.zone_inventory_quantity(zone)
      end
    end
  end

  describe "#packed_inventory_quantity_in_days" do
    it 'converts packed_inventory_quantity to days' do
      product.expects(:packed_inventory_quantity).returns(100)
      product.expects(:reserved).returns(3)
      assert_equal 33.3, product.packed_inventory_quantity_in_days
    end
  end

  describe "#made_inventory_ingredients_cost" do
    let(:product) { create :product }
    let(:make_zone) { create :zone, :make }

    it "delegates call to #make_product_inventory_record" do
      inventory = create :product_inventory, product: product, zone: make_zone
      inventory.stubs(:total_spent_ingredients_cost).returns(1000)
      product.stubs(:make_product_inventory_record).returns(inventory)
      assert_equal 1000, product.made_inventory_ingredients_cost
    end

    describe "when #make_product_inventory_record is not found" do
      it "returns 0" do
        assert_equal 0, product.made_inventory_ingredients_cost
      end
    end
  end

  describe "#packed_inventory_ingredients_cost" do
    let(:product) { create :product }
    let(:pack_zone) { create :zone, :pack }

    it "delegates call to #pack_product_inventory_record" do
      inventory = create :product_inventory, product: product, zone: pack_zone
      inventory.stubs(:total_spent_ingredients_cost).returns(1000)
      product.stubs(:pack_product_inventory_record).returns(inventory)
      assert_equal 1000, product.packed_inventory_ingredients_cost
    end

    describe "when #pack_product_inventory_record is not found" do
      it "returns 0" do
        assert_equal 0, product.packed_inventory_ingredients_cost
      end
    end
  end
end
