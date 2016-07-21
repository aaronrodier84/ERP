require 'test_helper'

class AddHistoryTest < ActiveSupport::TestCase

  let(:action) { AmazonInventories::AddHistory.new }

  before { @amazon_inventory = create :amazon_inventory }

  after { Timecop.return }

  describe 'when amazon inventory is nil' do
    it 'returns failure result' do
      result = action.call nil
      assert result.failure?
    end
  end

  it 'creates new amazon history' do
    assert_difference 'AmazonInventoryHistory.count', +1 do
      action.call @amazon_inventory
    end
  end

  it 'is successful' do
    result = action.call @amazon_inventory
    assert result.success?
  end

  it 'takes amazon history params from amazon inventory' do
    inventory = create :amazon_inventory, fulfillable: 100, reserved: 200,
                            inbound_working: 300, inbound_shipped: 400
    result = action.call inventory
    history_entity = result.entity
    assert_equal 100, history_entity.fulfillable
    assert_equal 200, history_entity.reserved
    assert_equal 300, history_entity.inbound_working
    assert_equal 400, history_entity.inbound_shipped
  end

  it 'uses current time as reported_at' do
    result = action.call @amazon_inventory
    history_entity = result.entity
    assert_equal Time.now.utc.to_formatted_s(:db), history_entity.reported_at.to_formatted_s(:db)
  end

  it 'saves amazon inventory to history association' do
    result = action.call @amazon_inventory
    history_entity = result.entity
    assert_equal @amazon_inventory, history_entity.amazon_inventory
  end

  describe 'when cannot save amazon history' do
    before { AmazonInventoryHistory.any_instance.stubs(:save).returns(false)}
    it 'returns failure as result' do
      result = action.call @amazon_history
      assert result.failure?
    end
  end
end
