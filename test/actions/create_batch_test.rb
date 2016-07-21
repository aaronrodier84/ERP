require 'test_helper' 

class CreateBatchTest < ActiveSupport::TestCase
  let(:user) { create :user}
  let(:params) { {quantity: 20, user_ids: [user.id]}}
  let(:success_result) { stub(success?: true)}
  let(:update_inventory_action) { stub(call: success_result)}

  let(:action) { described_class.new(update_inventory_action)}

  describe 'when params are valid' do
    it 'creates a batch' do
      assert_difference 'Batch.count', +1 do
        action.call(params)
      end
    end

    it 'returns successful result' do
      result = action.call(params)
      assert result.success?
    end

    it 'calls an action to update inventory with new amount' do
      update_inventory_action.expects(:call).once.returns(success_result)
      action.call params
    end
  end

  describe 'when unable to create' do
    before { Batch.any_instance.stubs(:save).returns(false) }
    it 'returns failed result' do
      update_inventory_action.stubs(:rollback)
      result = action.call params
      assert result.failure?
    end

    it 'rollbacks inventory changes' do
      update_inventory_action.expects(:rollback).once
      action.call params
    end
  end

  describe 'when encounters an error while updating inventories' do

    let(:failure_result) { stub(success?: false) }
    let(:update_inventory_action) { stub(call: failure_result)}
    let(:action) { described_class.new(update_inventory_action) }

    it 'returns failure result' do
      result = action.call params
      assert result.failure?
    end

    it 'does not create batch' do
      assert_no_difference 'Batch.count' do
        action.call params
      end
    end
  end
end
