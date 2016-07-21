# == Schema Information
#
# Table name: product_inventories
#
#  id         :integer          not null, primary key
#  quantity   :integer          default(0)
#  product_id :integer
#  zone_id    :integer
#

require 'test_helper' 

class ProductInventoryTest < ActiveSupport::TestCase

  describe '#debit' do
    it 'decreases product inventory in this zone on specified amount' do
      inventory = described_class.new quantity: 10
      assert_difference 'inventory.quantity', -5 do
        inventory.debit 5
      end
    end

    it 'saves updated inventory' do
      inventory = described_class.new quantity: 10
      refute inventory.persisted?
      inventory.debit 5
      assert inventory.persisted?
    end

    it 'raises an exception for not positive amounts' do
      inventory = described_class.new quantity: 10

      assert_raise ArgumentError do
        inventory.debit(-1)
      end
    end
  end

  describe '#credit' do
    it 'increases product inventory in this zone on specified amount' do
      inventory = described_class.new quantity: 10
      assert_difference 'inventory.quantity', 5 do
        inventory.credit 5
      end
    end

    it 'saves updated inventory' do
      inventory = described_class.new quantity: 10
      refute inventory.persisted?
      inventory.credit 5
      assert inventory.persisted?
    end

    it 'raises an exception for non positive amounts' do
      inventory = described_class.new quantity: 10

      assert_raise ArgumentError do
        inventory.credit(-1)
      end
    end
  end

  describe '.ordered_by_zone' do
    let(:product) { create :product }
    it 'orders inventories according to zones order' do
      zone_100, zone_50, zone_200 = zones = [100, 50, 200].map { |order| create :zone, production_order: order }

      zones.each { |zone| ProductInventory.create product: product, zone: zone }

      assert_equal [zone_50, zone_100, zone_200 ], ProductInventory.ordered_by_zone.map(&:zone)
    end
  end

  describe '.for_visible_zones_only' do
    let(:visible_zone)   { create :zone, :visible }
    let(:invisible_zone) { create :zone, :invisible }
    
    it 'returns inventories with visible zones only' do
      visible_zone_inventory   = create :product_inventory, zone: visible_zone
      invisible_zone_inventory = create :product_inventory, zone: invisible_zone

      inventories = ProductInventory.for_visible_zones_only

      assert     inventories.include?(  visible_zone_inventory)
      refute inventories.include?(invisible_zone_inventory)
    end
  end

  describe "#zone_ingredients_cost" do
    let(:product) { create :product }
    let(:zone) { create :zone }
    let(:inventory) { described_class.new(product: product, zone: zone, quantity: 11) }

    it "returns costs spent on the available amount of product in this zone only" do
      product.expects(:zone_ingredients_cost).with(zone).returns(5.99)
      assert_equal 5.99 * 11, inventory.zone_ingredients_cost
    end
  end

  describe "#total_spent_ingredients_cost" do
    let(:product) { create :product }
    let(:zone) { create :zone }
    let(:inventory) { described_class.new(product: product, zone: zone, quantity: 22) }

    it "returns costs spent on the available amount of product so far" do
      product.expects(:cumulative_zone_ingredients_cost).with(zone).returns(8.99)
      assert_equal 8.99 * 22, inventory.total_spent_ingredients_cost
    end
  end

end
