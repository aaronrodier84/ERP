require 'test_helper'

class UpdateAmazonInventoryTest < ActiveSupport::TestCase

  def described_class
    AmazonInventories::UpdateAmazonInventory
  end

  let(:params) { {reserved: 100, inbound_shipped: 200 }}
  let(:add_history_action) { stub(call: true)}
  let(:action) { described_class.new(add_history_action)}

  describe 'when amazon inventory is nil' do
    it 'returns failure' do
      result = action.call nil, params
      assert result.failure?
    end
  end

  describe 'when params are ok' do
    let(:amazon_inventory) { create :amazon_inventory }

    it 'is successful' do
      result = action.call amazon_inventory, params
      assert result.success?
    end

    it 'adds unchanged inventory to history' do
      add_history_action.expects(:call).once
      action = described_class.new add_history_action
      action.call amazon_inventory, params 
    end
    
    it 'smoothes reserved number before updating' do
      AmazonInventoryHistory.stubs(:smooth_reserved).returns(150)
      result = action.call amazon_inventory, params
      updated_inventory = result.entity
      assert_equal 150, updated_inventory.reserved
    end

    it 'updates amazon inventory' do
      action.call amazon_inventory, params
      updated_inventory = amazon_inventory.reload
      assert_equal 100, updated_inventory.reserved 
      assert_equal 200, updated_inventory.inbound_shipped
    end

    describe 'when unable to save amazon inventory' do
      before { AmazonInventory.any_instance.stubs(:save).returns(false)}
      it 'returns failure' do
        result = action.call amazon_inventory, params
        assert result.failure? 
      end
    end
  end




end
