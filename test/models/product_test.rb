# == Schema Information
#
# Table name: products
#
#  id                       :integer          not null, primary key
#  title                    :string
#  seller_sku               :string
#  asin                     :text
#  fnsku                    :string
#  size                     :string
#  list_price_amount        :string
#  list_price_currency      :string
#  total_supply_quantity    :integer
#  in_stock_supply_quantity :integer
#  small_image_url          :string
#  is_active                :boolean          default(TRUE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  inbound_qty              :float            default(0.0)
#  sold_last_24_hours       :float            default(0.0)
#  weeks_of_cover           :float            default(0.0)
#  sellable_qty             :float            default(0.0)
#  internal_title           :string
#  sales_rank               :integer
#  selling_price_amount     :float
#  selling_price_currency   :string
#

require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  describe '.active' do
    it 'returns only active products' do
      active_product = create :product, :active
      create :product, is_active: false

      assert_equal [active_product], Product.active
    end
  end

  describe '.inactive' do
    it 'returns only inactive products' do
      create :product, :active
      not_active_product = create :product, is_active: false
      assert_equal [not_active_product], Product.inactive
    end
  end

  describe '#available_inventories' do
    it 'gets only inventories for available for product zones' do
      product = create :product
      zones = create_list(:zone, 3)
      zone_1, zone_2, _ = zones
      [zone_1, zone_2].each { |zone| ProductZoneAvailability.create product: product, zone: zone }
      inventories = zones.map { |zone| ProductInventory.create product: product, zone: zone}
      assert_equal inventories.take(2) , product.available_inventories
    end
  end

  describe '#total_inventory' do
    let(:product) { create :product }

    before do
      @zone = create :zone, name: 'Pack'
    end

    it 'is sum of amazon fulfillable and shipped products and products in pack' do
      create :product_inventory, product: product, zone: @zone, quantity: 100
      product.amazon_inventory = build :amazon_inventory, fulfillable: 200, inbound_shipped: 300 
      assert_equal 100+200+300, product.total_inventory
    end

    describe 'when pack inventory empty' do
      it 'assumes its quantity is 0' do
        product.amazon_inventory = build :amazon_inventory, fulfillable: 200, inbound_shipped: 300 
        assert_equal 200+300, product.total_inventory
      end
    end
  end

  describe '#destroy' do
    let(:product) { create :product }

    it 'also destroys associated ingredients' do
      ingredient = create :ingredient, product: product

      assert_difference [->{Product.count}, ->{Ingredient.count}], -1 do
        product.destroy
      end
    end
  end
end
