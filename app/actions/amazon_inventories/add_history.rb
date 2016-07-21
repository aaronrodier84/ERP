module AmazonInventories
  class AddHistory

    def call(amazon_inventory)
      return StoreResult.new(entity: nil, success: false, errors: ['Amazon inventory could not be nil']) unless amazon_inventory

      params = prepair_history_attributes(amazon_inventory)
      inventory_history = AmazonInventoryHistory.new params
      save inventory_history
    end

    private

    def prepair_history_attributes(amazon_inventory)
      allowed_attributes = %i(fulfillable reserved inbound_working inbound_shipped)

      params = amazon_inventory.attributes.select { |attr| allowed_attributes.include?(attr.to_sym)}
      params.merge! reported_at: Time.now.utc, amazon_inventory: amazon_inventory
      params
    end

    def save(inventory_history)
      if inventory_history.save
        StoreResult.new entity: inventory_history, success: true
      else
        StoreResult.new entity: inventory_history, success: false, errors: inventory_history.errors
      end
    end
  end
end
