require 'test_helper'

class Products::ExposeProductsTest < ActiveSupport::TestCase

  let(:product) { create :product }
  let(:subject) { described_class.new }

  describe '#expose_to_all_zones' do
    before { create_list :zone, 2 }

    it 'assigns product to all available zones' do
      assert_difference 'product.zones.count', 2 do
        subject.expose_to_all_zones(product)
      end
    end

    describe 'when product already has zones available' do
      it 'does not make it available for other zones' do
        zone = Zone.first
        refute_nil zone
        ProductZoneAvailability.create product: product, zone: zone
        assert product.has_zones_available?
        assert_no_difference 'product.zones.count' do
          subject.expose_to_all_zones(product)
        end
      end
    end
  end
end
