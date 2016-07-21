module AmazonInventories
  class UpdateAmazonInventory

    def initialize(add_history_action = AddHistory.new)
      @add_history_action = add_history_action
    end

    def call(amazon_inventory, params)
      return StoreResult.new(entity: amazon_inventory, success: false, errors: 'amazon_inventory is empty') unless amazon_inventory

      add_history_action.call amazon_inventory

      updated_params = prepair_params(params)
      amazon_inventory.attributes = updated_params
      save amazon_inventory
    end

    private
    attr_reader :add_history_action

    def prepair_params(params)
      if params[:reserved]
        reserved = AmazonInventoryHistory.smooth_reserved(params[:reserved])
        params[:reserved] = reserved
      end
      params
    end

    def save(amazon_inventory)
      if amazon_inventory.save
        StoreResult.new entity: amazon_inventory, success: true, errors: nil
      else
        StoreResult.new entity: amazon_inventory, success: false, errors: amazon_inventory.errors
      end
    end
  end
end
