# == Schema Information
#
# Table name: amazon_inventory_histories
#
#  id                  :integer          not null, primary key
#  fulfillable         :integer
#  reserved            :integer
#  inbound_working     :integer
#  inbound_shipped     :integer
#  reported_at         :datetime
#  amazon_inventory_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class AmazonInventoryHistoryTest < ActiveSupport::TestCase

  describe '.smooth_reserved' do
    it 'smoothes new value by calculating average with last 2 entries' do
      create :amazon_inventory_history, reserved: 100
      create :amazon_inventory_history, reserved: 200
      smoothed_value = described_class.smooth_reserved 500
      assert_equal (100 + 200 + 500)/3.to_f, smoothed_value
    end

    it 'tries to convert provided value to number' do
      create :amazon_inventory_history, reserved: 100
      create :amazon_inventory_history, reserved: 200
      smoothed_value = described_class.smooth_reserved '123.5'
      assert_equal (100 + 200 + 123.5)/3.to_f, smoothed_value
    end

    describe 'when history is not available' do
      it 'returns the value itself' do
        smoothed_value = described_class.smooth_reserved 500
        assert_equal 500, smoothed_value
      end
    end
  end
end
