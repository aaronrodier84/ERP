require 'test_helper'

class ProductPresenterTest < ActiveSupport::TestCase
  let(:product) { build :product }
  let(:presenter) { described_class.new product }

  describe '#amazon_coverage_ratio_limited' do
    it 'returns product amazon coverage ratio if it is <= 100%' do
      product.stubs(:amazon_coverage_ratio).returns(22)
      assert_equal 22, presenter.amazon_coverage_ratio_limited

      product.stubs(:amazon_coverage_ratio).returns(100)
      assert_equal 100, presenter.amazon_coverage_ratio_limited
    end

    it 'returns 100% id product amazon coverage ratio is > 100%' do
      product.stubs(:amazon_coverage_ratio).returns(101)
      assert_equal 100, presenter.amazon_coverage_ratio_limited

      product.stubs(:amazon_coverage_ratio).returns(500)
      assert_equal 100, presenter.amazon_coverage_ratio_limited
    end
  end
end
