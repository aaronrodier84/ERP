require 'test_helper'

class CombinedResultTest < ActiveSupport::TestCase

  describe 'when all results are successful' do
    let(:results) { 3.times.map { stub(success?: true)} }
    
    it 'is successful as well' do
      combined_result = described_class.new(*results)
      assert combined_result.success?
    end

    it 'is not a failure' do
      combined_result = described_class.new(*results)
      refute combined_result.failure?
    end
  end

  describe 'when at least one result is not successful' do
    let(:results) { 3.times.map { stub(success?: true)} << stub(success?: false) }

    it 'is not successful' do
      combined_result = described_class.new(*results)
      refute combined_result.success?
    end

    it 'is a failure' do
      combined_result = described_class.new(*results)
      assert combined_result.failure?
    end
  end

  describe '#entity' do
    it 'gets first available entity from results' do
      entity_1, entity_2 = Object.new, Object.new
      entities = [nil, nil, entity_1, nil, entity_2]
      results = entities.map { |entity| stub(entity: entity)}
      combined_result = described_class.new(*results)
      assert_equal entity_1, combined_result.entity
    end

    it 'is nil when no entities available' do
      entities = [nil, nil, nil]
      results = entities.map { |entity| stub(entity: entity)}
      combined_result = described_class.new(*results)
      assert_nil combined_result.entity
    end
  end

  describe '#errors' do
    it 'merges all errors into single array' do
      result_1 = stub(errors: ["error_1", "error_2"])
      result_2 = stub(errors: ["error_3"])
      result_3 = stub(errors: ["error_1"])
      combined_result = described_class.new result_1, result_2, result_3
      assert_equal %w(error_1 error_2 error_3 error_1), combined_result.errors
    end

    it 'filters all empty errors' do
      result_1 = stub(errors: [])
      result_2 = stub(errors: ["error_1", nil, "error_2"])
      result_3 = stub(errors: ["error_4", nil, nil])
      combined_result = described_class.new result_1, result_2, result_3
      assert_equal %w(error_1 error_2 error_4), combined_result.errors
    end
  end
end
