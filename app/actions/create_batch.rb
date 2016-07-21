class CreateBatch
  include FormattedDate

  def initialize(update_inventory_action = Products::MoveProductsInBatch.new)
    @update_inventory_action = update_inventory_action
  end

  def call(params)
    batch = init_batch params
    update_inventory_result = update_inventory_action.call(batch)

    store_result = update_inventory_result.success? ? save_batch(batch) : nil

    update_inventory_action.rollback if store_result&.failure?

    store_result ||= StoreResult.new entity: batch, success: false, errors: ['Batch was not created:']

    CombinedResult.new store_result, update_inventory_result
  end

  private

  attr_reader :update_inventory_action

  def init_batch(params)
    batch = Batch.new params      
    if params[:completed_on] && batch.valid?
      batch.completed_on = friendly_string_to_date(params[:completed_on])
    end
    batch
  end

  def save_batch(batch)
    if batch.save
      StoreResult.new entity: batch, success: true
    else
      StoreResult.new entity: batch, success: false, errors: batch.errors
    end
  end
end
