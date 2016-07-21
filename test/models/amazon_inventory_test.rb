# == Schema Information
#
# Table name: amazon_inventories
#
#  id              :integer          not null, primary key
#  fulfillable     :integer          default(0)
#  reserved        :integer          default(0)
#  inbound_working :integer          default(0)
#  inbound_shipped :integer          default(0)
#  product_id      :integer
#

require 'test_helper'

class AmazonInventoryTest < ActiveSupport::TestCase
  describe "#total_amazon_inventory" do
    it "sums fulfillable and inbound shipped" do
      inventory = described_class.new inbound_shipped: 10, fulfillable: 5
      assert_equal 10 + 5, inventory.total_amazon_inventory
    end
  end

  describe '#days_of_cover' do
    it 'is is ratio of (fulfillable + inbound_shipped) to reserved' do
      inventory = described_class.new fulfillable: 4, inbound_shipped: 6, reserved: 3
      assert_equal 3.3, inventory.days_of_cover
    end

    describe 'when fulfillable and inbound_shipped are zeros' do
      it 'does not have any days of cover' do
        inventory = described_class.new fulfillable: 0, inbound_shipped: 0, reserved: 100
        assert_equal 0, inventory.days_of_cover
      end
    end

    describe 'when reserved is zero' do
      it 'calculates days of cover assuming that at least 1 reserved' do
        inventory = described_class.new fulfillable: 5, inbound_shipped: 6, reserved: 0
        assert_equal 11, inventory.days_of_cover
      end
    end
  end

  describe '#days_to_cover' do
    let(:product) { create :product, production_buffer_days: 29 }

    it 'is how many days it is left to cover on Amazon' do
      inventory = described_class.new(product: product)
      inventory.stubs(:days_of_cover).returns(8.2)
      assert_equal 29 - 8.2, inventory.days_to_cover
    end

    describe 'when Amazon warehouse is overstocked' do
      it 'returns 0 (cannot be negative)' do
        inventory = described_class.new(product: product)
        inventory.stubs(:days_of_cover).returns(100)
        assert_equal 0, inventory.days_to_cover
      end
    end
  end

  describe '#coverage_ratio' do
    let(:product) { create :product, production_buffer_days: 60 }

    it 'is a % ratio of days_of_cover to shipment buffer in days' do
      inventory = described_class.new(product: product)
      inventory.stubs(:days_of_cover).returns(20)
      assert_equal 33, inventory.coverage_ratio
    end

    it 'can easily be > 100% (in case of overstock)' do
      inventory = described_class.new(product: product)
      inventory.stubs(:days_of_cover).returns(210)
      assert_equal 350, inventory.coverage_ratio
    end
  end
end
