module Fba
  class UpdateFbaAllocation

    def call(fba_allocation, fba_warehouse_params)
      return StoreResult.new(entity: fba_allocation, success: false, errors: ['FBA allocation is nil']) unless fba_allocation

      if fba_allocation.update fba_warehouse_params
        return StoreResult.new entity: fba_allocation, success: true, errors: nil
      else
        return StoreResult.new entity: fba_allocation, success: false, errors: fba_allocation.errors
      end
    end
  end
end
