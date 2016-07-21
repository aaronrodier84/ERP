require 'test_helper'

class CreateProductTest < ActiveSupport::TestCase

  let(:success_result) { stub(success?: true)}
  let(:product_exposer) { stub(expose_to_all_zones: true)}

  let(:params) {{ title: 'Some oil', size: 'big', weeks_of_cover: 10 }}

  let(:action) { Products::CreateProduct.new(product_exposer)}

  describe 'when params are valid' do
    it 'creates a product' do
      assert_difference 'Product.count', +1 do
        action.call params
      end
    end

    it 'returns successful result' do
      result = action.call params
      assert result.success?
    end

    it 'exposes product to all zones' do
      product_exposer.expects(:expose_to_all_zones).returns(true)
      action.call params
    end

    it 'creates amazon inventory for product' do
      assert_difference 'AmazonInventory.count', +1 do
        action.call params
      end
    end

    it 'creates product inventories for product' do
      create_list :zone, 2
      assert_difference 'ProductInventory.count', +2 do
        action.call params
      end
    end
  end

  describe 'when unable to create' do
    before { Product.any_instance.stubs(:save).returns(false)}

    it 'returns failure' do
      result = action.call params
      assert result.failure?
    end

    it 'does not expose product' do
      product_exposer.expects(:expose_to_all_zones).never
      action.call params
    end

    it 'does not create amazon inventory' do
      assert_no_difference 'AmazonInventory.count' do
        action.call params
      end
    end

    it 'does not create any product inventories' do
      assert_no_difference 'ProductInventory.count' do
        action.call params
      end
    end
  end
end
