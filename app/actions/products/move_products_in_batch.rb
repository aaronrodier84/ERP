module Products
  class MoveProductsInBatch
    include Logging

    def initialize(zones_workflow = ZoneWorkflow)
      @zones_workflow = zones_workflow
      @context = OpenStruct.new
    end

    def call(batch, old_batch = nil)
      previous_amount = old_batch&.quantity || 0
      amount = batch.quantity - previous_amount
      return TransactionResult.new(success: true, errors: nil) if amount == 0

      source_inventory, destination_inventory = define_inventories batch, amount

      move_products(source_inventory, destination_inventory, amount.abs)
    end

    def rollback
      move_products(context.destination_inventory, context.source_inventory, context.amount)
    end

    private

    def define_inventories(batch, amount)
      source_zone, destination_zone = define_zones batch.product, batch.zone, amount

      source_zone_inventory = ProductInventory.find_by product: batch.product, zone: source_zone
      destination_zone_inventory = ProductInventory.find_by product: batch.product, zone: destination_zone
      [source_zone_inventory, destination_zone_inventory]
    end

    def define_zones(product, current_zone, amount)
      workflow = @zones_workflow.new(product&.zones)
      amount > 0 ? [workflow.previous_zone(current_zone), current_zone]
                 : [current_zone, workflow.previous_zone(current_zone)]
    end

    def move_products(from, to, amount)
      log "Moving from #{from} to #{to} #{amount} of product"
      ProductInventory.transaction do
        from.debit(amount) if from
        to.credit(amount) if to
      end
      store_context(from, to, amount)
      log 'Products transfered'
      TransactionResult.new success: true, errors: nil
    rescue ActiveRecord::RecordInvalid => invalid_record
      TransactionResult.new success: false, failed: [invalid_record], errors: ["Cannot transfer products. Make you sure you have enough product in source zone"]
    end

    def store_context(source_inventory, destination_inventory, amount)
      context.source_inventory = source_inventory
      context.destination_inventory = destination_inventory
      context.amount = amount
    end

    attr_reader :logger, :context
  end
end
