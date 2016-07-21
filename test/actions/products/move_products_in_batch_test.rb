require 'test_helper' 

class Products::MoveProductsInBatchTest < ActiveSupport::TestCase

  let(:product) { create :product }
  
  let(:current_zone) { Zone.create production_order: 2}
  let(:previous_zone) { Zone.create production_order: 1}

  let(:batch) { Batch.new product: product, zone: current_zone, quantity: 10 }

  before do
    [current_zone, previous_zone].each { |zone| ProductZoneAvailability.create product: product, zone: zone }
    @current_zone_inventory = ProductInventory.create product: product, zone: current_zone, quantity: 100
    @previous_zone_inventory = ProductInventory.create product: product, zone: previous_zone, quantity: 150 
  end

  describe 'when batch is new' do

    it 'moves all products from previous zone to current' do
      diff = { '@previous_zone_inventory.reload.quantity' => -10,
               '@current_zone_inventory.reload.quantity' => +10}
      action = described_class.new
      assert_differences diff do
        action.call(batch)
      end
    end

    describe 'when moving more than exists in previous zone' do
      let(:wrong_batch) { Batch.new product: product, zone: current_zone, quantity: 300 }

      it 'returns with failure' do
        action = described_class.new
        result = action.call wrong_batch
        assert result.failure?
      end

      it 'does not change source inventory' do
        action = described_class.new
        assert_no_difference '@previous_zone_inventory.reload.quantity' do
          action.call wrong_batch
        end
      end

      it 'does not change destination inventory' do
        action = described_class.new
        assert_no_difference '@current_zone_inventory.reload.quantity' do
          action.call wrong_batch
        end
      end
    end
    
    it 'returns successful result' do
      action = described_class.new
      result = action.call(batch)
      assert result.success?
    end

    describe 'when zone is first' do
      let(:workflow) { stub(previous_zone: nil)}

      it 'just updates current zone inventory' do
        action = described_class.new
        assert_difference '@current_zone_inventory.reload.quantity', +10 do
          action.call(batch)
        end
      end
    end
  end

  describe 'when batch is updating' do
    describe 'when amount is increased on update' do
      let(:old_batch) { Batch.new product: product, zone: current_zone, quantity: 5}

      it 'adds difference to current zone' do
        assert_equal 5, batch.quantity - old_batch.quantity
        action = described_class.new
        assert_difference '@current_zone_inventory.reload.quantity', +5 do
          action.call(batch, old_batch)
        end
      end

      it 'subtracts amount from previous zone inventory' do
        assert_equal 5, batch.quantity - old_batch.quantity
        action = described_class.new
        assert_difference '@previous_zone_inventory.reload.quantity', -5 do
          action.call(batch, old_batch)
        end
      end

      describe 'when updated batch trying to move more than exists in previous zone' do
        let(:wrong_new_batch) { Batch.new product: product, zone: current_zone, quantity: 150 }

        it 'returns with failure' do
          action = described_class.new
          result = action.call old_batch, wrong_new_batch
          assert result.failure?
        end

        it 'does not change source inventory' do
          action = described_class.new
          assert_no_difference '@previous_zone_inventory.reload.quantity' do
            action.call old_batch, wrong_new_batch
          end
        end

        it 'does not change destination inventory' do
          action = described_class.new
          assert_no_difference '@current_zone_inventory.reload.quantity' do
            action.call old_batch, wrong_new_batch
          end
        end
    end
    end

    describe 'when amount is decreased on update' do
      let(:old_batch) { Batch.new product: product, zone: current_zone, quantity: 15}

      it 'subtracts difference from current zone' do
        assert_equal(-5, batch.quantity - old_batch.quantity)
        action = described_class.new
        assert_difference '@current_zone_inventory.reload.quantity', -5 do
          action.call(batch, old_batch)
        end
      end

      it 'adds difference to previous zone' do
        assert_equal(-5, batch.quantity - old_batch.quantity)
        action = described_class.new
        assert_difference '@previous_zone_inventory.reload.quantity', +5 do
          action.call(batch, old_batch)
        end
      end
    end
  end

  describe '.rollback' do

    it 'rollbacks inventory changes after new batch' do
      diff = [ '@previous_zone_inventory.reload.quantity',
               '@current_zone_inventory.reload.quantity']
      action = described_class.new
      assert_no_differences diff do
        action.call(batch)
        action.rollback
      end
    end

    it 'rollbacks inventory changes after batch update' do
      new_batch = Batch.new product: product, zone: current_zone, quantity: batch.quantity + 10

      action = described_class.new 
      diff = [ '@previous_zone_inventory.reload.quantity',
               '@current_zone_inventory.reload.quantity']
      assert_no_differences diff do
        action.call(batch, new_batch)
        action.rollback
      end
    end
  end

  it 'stores source inventory in context' do
      end
end
