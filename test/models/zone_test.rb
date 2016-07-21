# == Schema Information
#
# Table name: zones
#
#  id                     :integer          not null, primary key
#  name                   :string
#  production_order       :integer
#  production_buffer_days :integer          default(30), not null
#

require 'test_helper'

class ZoneTest < ActiveSupport::TestCase

  describe '#slug' do
    it 'is downcased name' do
      zone = Zone.new name: 'AbCdEF'
      assert_equal 'abcdef', zone.slug
    end
  end

  describe '#active_products' do
    let(:zone) { create :zone }

    it 'fetches active products that belong to this zone' do
      active_product_for_zone = Product.create is_active: true
      not_active_product_for_zone = Product.create is_active: false
      zone_products = [active_product_for_zone, not_active_product_for_zone]
      zone_products.each { |p| ProductZoneAvailability.create product: p, zone: zone }
      Product.create is_active: true

      assert_equal [active_product_for_zone], zone.active_products
    end
  end

  describe '.fetch_or_default' do
    it 'fetches zone by id' do
      zone = Zone.create 
      fetched_zone = Zone.fetch_or_default(zone.id)
      assert_equal zone, fetched_zone
    end

    it 'returns default zone if could not find zone by id' do
      default_zone = Zone.create name: 'some_default_zone'
      Zone.stub(:default_zone, -> { default_zone }) do
        non_existent_zone_id = default_zone.id + 100
        fetched_zone = Zone.fetch_or_default(non_existent_zone_id)
        assert_equal default_zone, fetched_zone
      end
    end
  end

  describe '.default_zone' do
    it 'is "Make" zone' do
      Zone.create(name: 'Pack')
      make_zone = Zone.create(name: 'Make')
      assert_equal make_zone, Zone.default_zone
    end

    it 'is nil if "Make" zone not exists' do
      assert_nil Zone.default_zone
    end
  end

  describe '.visible' do
    it 'returns make and pack zones' do
      make_zone = create :zone, name: 'Make'
      pack_zone = create :zone, name: 'Pack'
      another_zone = create :zone, name: 'Whatever'

      visible_zones = Zone.visible
      assert     visible_zones.include?(make_zone)
      assert     visible_zones.include?(pack_zone)
      refute visible_zones.include?(another_zone)
    end
  end
end
