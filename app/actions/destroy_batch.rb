class DestroyBatch

  def initialize(update_inventory_action = Products::MoveProductsInBatch.new)
    @update_inventory_action = update_inventory_action
  end

  def call(batch) 
    return StoreResult.new(entity: batch, success: false, errors: 'Batch is nil') unless batch

    empty_batch = batch.dup.tap { |b| b.quantity = 0 }

    inventory_change_result = update_inventory_action.call(empty_batch, batch)
    destroy_result = inventory_change_result.success? ? destroy_batch(batch) : nil

    update_inventory_action.rollback if destroy_result&.failure?

    destroy_result ||= StoreResult.new entity: batch, success: false, errors: ['Batch was not deleted:']
    CombinedResult.new destroy_result, inventory_change_result
  end

  private
  attr_reader :update_inventory_action

  def destroy_batch(batch)
    if batch.destroy
      StoreResult.new entity: batch, success: true, errors: nil
    else
      StoreResult.new entity: batch, success: false, errors: batch.errors
    end
  end
end
