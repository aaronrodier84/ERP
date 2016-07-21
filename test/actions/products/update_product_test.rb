require 'test_helper'

class UpdateProductTest < ActiveSupport::TestCase

  let(:subject) { Products::UpdateProduct.new }
  let(:default_zone) { create :zone }

  before do
    Zone.stubs(:default_zone).returns(default_zone)
  end

  describe 'when product is empty' do
    it 'returns failure result' do
      result = subject.call nil, { size: 100 } 
      assert result.failure?
    end
  end

  describe 'when zone_ids param is missing' do
    it 'does not change product zone availabilities' do
      product = create :product
      zones = create_list :zone, 2
      zones.each { |zone| ProductZoneAvailability.create product: product, zone: zone }

      assert_equal 2, product.product_zone_availabilities.count
      assert_no_difference 'product.product_zone_availabilities.count' do
        subject.call product, { internal_title: 'boo' }
      end
    end
  end

  describe 'when params are ok' do
    let(:product) { create :product, size: 100, is_active: false }

    it 'saves changed product' do
      subject.call product, { size: 200} 
      assert_equal '200', product.reload.size
    end

    it 'does not update fields not specified in params' do
      subject.call product, { size: 200 }
      refute product.reload.is_active
    end

    describe 'when can successfully save' do
      it 'returns successful result' do
        result = subject.call product, { size: 200 }
        assert result.success?
      end
    end

    describe 'when cannot successfully save' do
      it 'returns failure result' do
        product.stubs(:save).returns(false)
        result = subject.call product, { size: 200}
        assert result.failure?
      end
    end
    
    it 'updates product zone availabilities as well' do
      zones = create_list :zone, 2
      ProductZoneAvailability.create product: product, zone: zones.first
      subject.call product, { zone_ids: zones.map(&:id)}
      assert_equal zones.count, product.product_zone_availabilities.count
    end

    it 'always keeps at least one zone available' do
      zones = create_list :zone, 2
      zones.each { |zone| ProductZoneAvailability.create product: product, zone: zone }
      subject.call product, { zone_ids: []}
      assert_equal 1, product.product_zone_availabilities.count
    end
  end
end
