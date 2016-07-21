# frozen_string_literal: true
require 'test_helper'

class ProductConcerningAmazonInventoriesTest < ActiveSupport::TestCase
  describe '#fulfillable' do
    let(:product) { build :product }

    it 'delegates call to amazon inventory' do
      product.amazon_inventory = build :amazon_inventory, fulfillable: 111
      assert_equal 111, product.fulfillable
    end

    it 'is 0 if amazon inventory is nil' do
      product.amazon_inventory = nil
      assert_equal 0, product.fulfillable
    end
  end

  describe '#reserved' do
    let(:product) { build :product }

    it 'delegates call to amazon inventory' do
      product.amazon_inventory = build :amazon_inventory, reserved: 222
      assert_equal 222, product.reserved
    end

    it 'is 0 if amazon inventory is nil' do
      product.amazon_inventory = nil
      assert_equal 0, product.reserved
    end
  end

  describe '#inbound_shipped' do
    let(:product) { build :product }

    it 'delegates call to amazon inventory' do
      product.amazon_inventory = build :amazon_inventory, inbound_shipped: 333
      assert_equal 333, product.inbound_shipped
    end

    it 'is 0 if amazon inventory is nil' do
      product.amazon_inventory = nil
      assert_equal 0, product.inbound_shipped
    end
  end

  describe '#inbound_working' do
    let(:product) { build :product }

    it 'delegates call to amazon inventory' do
      product.amazon_inventory = build :amazon_inventory, inbound_working: 444
      assert_equal 444, product.inbound_working
    end

    it 'is 0 if amazon inventory is nil' do
      product.amazon_inventory = nil
      assert_equal 0, product.inbound_working
    end
  end

  describe '#total_amazon_inventory' do
    let(:product) { build :product }

    it 'delegates call to amazon inventory' do
      product.amazon_inventory = build :amazon_inventory
      product.amazon_inventory.stubs(:total_amazon_inventory).returns(67)
      assert_equal 67, product.total_amazon_inventory
    end

    it 'is 0 if amazon inventory is nil' do
      product.amazon_inventory = nil
      assert_equal 0, product.total_amazon_inventory
    end
  end

  describe '#days_of_cover' do
    let(:product) { build :product }

    it 'delegates call to amazon inventory' do
      amazon_inventory = build :amazon_inventory
      amazon_inventory.stubs(:days_of_cover).returns(123)
      product.amazon_inventory = amazon_inventory
      assert_equal 123, product.days_of_cover
    end

    it 'is 0 if amazon inventory is nil' do
      product.amazon_inventory = nil
      assert_equal 0, product.days_of_cover
    end
  end

  describe '#days_to_cover' do
    let(:product) { build :product }

    it 'delegates call to amazon inventory' do
      amazon_inventory = build :amazon_inventory
      amazon_inventory.stubs(:days_to_cover).returns(23.5)
      product.amazon_inventory = amazon_inventory
      assert_equal 23.5, product.days_to_cover
    end
  end

  describe '#amazon_coverage_ratio' do
    let(:product) { build :product }

    it 'delegates call to amazon inventory' do
      amazon_inventory = build :amazon_inventory
      amazon_inventory.stubs(:coverage_ratio).returns(90)
      product.amazon_inventory = amazon_inventory
      assert_equal 90, product.amazon_coverage_ratio
    end
  end
end
