# frozen_string_literal: true
require 'test_helper'

class ProductionPlanPresenterTest < ActiveSupport::TestCase
  let(:product) { build :product }
  let(:presenter) { described_class.new product }

  describe "#to_ship_in_days" do
    it 'converts to_ship to days' do
      product.expects(:reserved).returns(3)
      presenter.expects(:to_ship).returns(100)
      assert_equal 33.3, presenter.to_ship_in_days
    end
  end
end
