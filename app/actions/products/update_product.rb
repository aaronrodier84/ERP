module Products
  class UpdateProduct

    def call(product, params)
      return StoreResult.new(entity: product, success: false, errors: 'Product is empty') unless product

      params = validate_params(params)

      product.attributes = params
      if product.save
        StoreResult.new entity: product, success: true, errors: nil
      else
        StoreResult.new entity: product, success: false, errors: product.errors
      end
    end

    def validate_params(params)
      if params[:zone_ids]
        all_zones_checked_out = params[:zone_ids].reject(&:blank?).blank?
        params[:zone_ids] = [Zone.default_zone.id] if all_zones_checked_out
      end
      params
    end
  end
end
