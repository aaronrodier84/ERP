require 'test_helper'

class DestroyBatchTest < ActiveSupport::TestCase

  let(:user) { create :user }

  let(:success_result) { stub(success?: true, failure?: false)}
  let(:update_inventory_action) { stub(call: success_result)}
  let(:action) { described_class.new(update_inventory_action)}

  before do
    @batch = create :batch, quantity: 100
  end

  describe 'when batch is nil' do
    it 'returns failure result' do
      result = action.call(nil)
      assert result.failure?
    end
  end

  describe 'when batch is ok' do
    it 'deletes batch' do
      assert_difference 'Batch.count', -1 do
        action.call @batch
      end
    end

    it 'returns successful result' do
      result = action.call @batch
      assert result.success?
    end

    it 'calls an action to update inventory with new amount' do
      update_inventory_action.expects(:call).once.returns(success_result)
      action = described_class.new(update_inventory_action)
      action.call @batch
    end
  end

  describe 'when unable to destroy batch' do
    before { @batch.stubs(:destroy).returns(false) }

    it 'returns a failure result' do
      update_inventory_action.stubs(:rollback).returns(success_result)
      result = action.call @batch
      assert result.failure?
    end

    it 'rollbacks inventory changes' do
      update_inventory_action.expects(:rollback).once
      action = described_class.new(update_inventory_action)
      action.call @batch
    end
  end

  describe 'when encounters error during inventory update' do
    let(:failure_result) { stub(success?: false)}
    let(:update_inventory_action) { stub(call: failure_result)}
    let(:action) { described_class.new(update_inventory_action)}

    it 'does not destroy batch' do
      assert_no_difference 'Batch.count' do
        action.call @batch
      end
    end

    it 'returns failure result' do
      result = action.call @batch
      assert result.failure?
    end
  end
end



