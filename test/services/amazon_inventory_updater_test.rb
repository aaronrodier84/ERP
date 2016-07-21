# frozen_string_literal: true
require 'test_helper'

class AmazonInventoryUpdaterTest < ActiveSupport::TestCase
  describe '.build' do
    it 'builds instance of updater with default dependencies' do
      updater = described_class.build
      assert_kind_of AmazonInventoryUpdater, updater
    end
  end
end
