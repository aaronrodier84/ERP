# frozen_string_literal: true
require 'test_helper'

class ProductAmountTest < ActiveSupport::TestCase
  describe '#days' do
    it 'converts items to days of/to cover' do
      assert_equal 3.3, described_class.new(10).days(3)
    end

    describe 'when items_per_day is 0' do
      it 'calculates days assuming that items_per_day is 1' do
        assert_equal 10, described_class.new(10).days(0)
      end
    end
  end

  describe '#cases' do
    it 'converts number of items to integral number of cases' do
      assert_equal 2, described_class.new(333).cases(150)
    end

    describe 'when items_per_case is 0' do
      it 'returns 0' do
        assert_equal 0, described_class.new(10).cases(0)
      end
    end

    describe 'when items_count is nil' do
      it 'returns 0' do
        assert_equal 0, described_class.new(nil).cases(150)
      end
    end
  end

  describe '#case_excess' do
    it 'returns excess number of items after partitioning to volumes' do
      assert_equal 33, described_class.new(333).case_excess(150)
    end

    describe 'when items_per_case is 0' do
      it 'returns 0' do
        assert_equal 0, described_class.new(10).case_excess(0)
      end
    end
  end

  describe '#case_excess_percent' do
    it 'returns excess % that would be left after partitioning to volumes' do
      assert_equal 0, described_class.new(300).case_excess_percent(150)
      assert_equal 33, described_class.new(350).case_excess_percent(150)
      assert_equal 98, described_class.new(98).case_excess_percent(100)
    end

    describe 'when items_per_case is 0' do
      it 'returns 0' do
        assert_equal 0, described_class.new(10).case_excess_percent(0)
      end
    end
  end
end
