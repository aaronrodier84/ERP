require 'test_helper'

class Fba::UpdateFbaAllocationTest < ActiveSupport::TestCase

  let(:product) { create :product}
  let(:fba_warehouse) { create :fba_warehouse}
  let(:fba_allocation) { create :fba_allocation, product: product, fba_warehouse: fba_warehouse}

  def described_class
    Fba::UpdateFbaAllocation
  end

  it 'update fba allocation record' do
    action = described_class.new
    action.call fba_allocation, {quantity: 5000}
    assert_equal 5000, fba_allocation.reload.quantity
  end

  it 'returns successful result' do
    action = described_class.new
    result = action.call fba_allocation, quantity: 5000
    assert result.success?
  end

  describe 'when params are invalid' do
    it 'returns failure result' do
      action = described_class.new
      result = action.call fba_allocation, quantity: nil
      assert result.failure?
    end
  end

  describe 'when fba allocation is nil' do
    it 'returns failure result' do
      action = described_class.new
      result = action.call nil, quantity: 5000
      assert result.failure?
    end
  end

end
