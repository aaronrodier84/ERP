require 'test_helper'

class ChangeBatchTest < ActiveSupport::TestCase

  let(:user) { create :user }
  let(:batch) { create :batch, quantity: 100 }
  let(:params) { {quantity: 50, user_ids: [user.id] }}
  let(:success_result) { stub(success?: true)}
  let(:failure_result) { stub(failure?: true, success?: false)}
  let(:update_inventory_action) { stub(call: success_result, rollback: success_result)}

  describe 'when batch is nil' do
    it 'returns failure result' do
      action = described_class.new(update_inventory_action)
      result = action.call(nil , params)
      assert result.failure?
    end
  end

  describe 'when arguments are valid' do
    it 'updates batch' do
      action = described_class.new(update_inventory_action)
      assert_difference 'batch.reload.quantity', -50 do
        action.call(batch, params)
      end
    end

    it 'returns successful result' do
      action = described_class.new(update_inventory_action)
      result = action.call(batch, params)
      assert result.success?
    end

    it 'calls an action to update inventory with new amount' do
      action = described_class.new(update_inventory_action)
      action.call(batch, params)
    end
  end

  describe 'when unable to save' do
    before { batch.stubs(:save).returns(false) }
    it 'result is a failure' do
      action = described_class.new(update_inventory_action)
      result = action.call(batch, params)
      assert result.failure?
    end

    it 'rollbacks inventory change' do
      update_inventory_action.expects(:rollback)
      action = described_class.new(update_inventory_action)
      action.call batch, params
    end
  end

  describe 'when encounters error during inventories update' do
    let(:update_inventory_action) { stub(call: failure_result, rollback: success_result)}
    let(:action) { described_class.new(update_inventory_action)}


    it 'does not update batch' do
      assert_no_difference 'batch.reload.quantity' do
        action.call batch, params
      end
    end

    it 'returns failure result' do
      result = action.call batch, params
      assert result.failure?
    end
  end
end
