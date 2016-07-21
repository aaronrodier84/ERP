class ChangeBatch
  include FormattedDate

  def initialize(update_inventory_action = Products::MoveProductsInBatch.new)
    @update_inventory_action = update_inventory_action
  end

  def call(batch, params)
    return StoreResult.new(entity: batch, success: false, errors: 'Entity is empty') unless batch

    old_batch = batch.dup

    change_batch(batch, params)

    inventory_change_result = update_inventory_action.call(batch, old_batch)

    store_result = inventory_change_result.success? ? save_batch(batch) : nil

    update_inventory_action.rollback if store_result&.failure?

    store_result ||= begin
      batch.restore_attributes
      StoreResult.new entity: batch, success: false, errors: ['Batch was not updated:']
    end

    CombinedResult.new store_result, inventory_change_result
  end

  private

  attr_reader :update_inventory_action

  def change_batch(batch, params)
    params[:completed_on] = friendly_string_to_date(params[:completed_on]) if params[:completed_on]
    batch.attributes = params
  end

  def save_batch(batch)
    if batch.save
      StoreResult.new entity: batch, success: true, errors: nil
    else
      StoreResult.new entity: batch, success: false, errors: batch.errors
    end
  end
end
