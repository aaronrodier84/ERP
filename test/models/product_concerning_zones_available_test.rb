# frozen_string_literal: true
require 'test_helper'

class ProductConcerningZonesAvailableTest < ActiveSupport::TestCase
  describe '#has_zones_available?' do
    let(:product) { create :product }
    it 'is true when product available to at least one zone' do
      zone = create :zone
      ProductZoneAvailability.create product: product, zone: zone
      assert product.has_zones_available?
      assert product.product_zone_availabilities.count > 0
    end

    it 'is false when product not available to any zone' do
      assert_equal 0, product.product_zone_availabilities.count
      refute product.has_zones_available?
    end
  end

  describe '#has_make_zone?' do
    let(:product) { create :product }

    it 'is true if product is associated with Make zone' do
      make_zone = create :zone, :make
      ProductZoneAvailability.create product: product, zone: make_zone
      assert product.has_make_zone?
    end

    it 'is false otherwise' do
      refute product.has_make_zone?
    end
  end

  describe '#has_pack_zone?' do
    let(:product) { create :product }

    it 'is true if product is associated with Make zone' do
      pack_zone = create :zone, :pack
      ProductZoneAvailability.create product: product, zone: pack_zone
      assert product.has_pack_zone?
    end

    it 'is false otherwise' do
      refute product.has_pack_zone?
    end
  end
end
