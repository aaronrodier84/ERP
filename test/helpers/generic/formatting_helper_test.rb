# frozen_string_literal: true
require 'test_helper'

class FormattingHelperTest < ActionView::TestCase
  include Generic::FormattingHelper

  describe 'with_currency' do
    describe "when price has no fractions of a cent" do
      it 'returns number_to_currency' do
        assert_equal number_to_currency(2.5), with_currency(2.5)
        assert_equal number_to_currency(2.51), with_currency(2.51)
      end
    end

    describe "when price has fractions of a cent" do
      it 'returns precise price with currency prefix' do
        assert_equal "$2.54321", with_currency(2.54321)
      end
    end

    it "overrides currency correctly" do
      assert_equal "USD2.51", with_currency(2.51, unit: "USD")
      assert_equal "USD2.54321", with_currency(2.54321, unit: "USD")
    end
  end
end
