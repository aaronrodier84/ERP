require 'test_helper'

class ProductsPresenterTest < ActiveSupport::TestCase

  let(:zone) { stub(id: 100)}

  it 'exposes active products' do
    presenter = described_class.new [1,2,3], zone
    assert_equal [1,2,3], presenter.products
  end

  describe '#zone_id' do
    it 'get specified zone id' do
      presenter = described_class.new [], zone
      assert_equal 100, presenter.zone_id
    end

    it 'is nil if zone is nil' do
      presenter = described_class.new [], nil
      assert_equal nil, presenter.zone_id
    end
  end
end
