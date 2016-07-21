module MwsStructs

  # structs for amazon inbound shipment request
  Address = Struct.new(:name, :address_line_1, :city, :state_or_province_code,
                       :postal_code, :country_code)
  Item = Struct.new(:seller_sku, :quantity, :prep_details_list)
  ItemShipped = Struct.new(:seller_sku, :quantity_shipped, :prep_details_list)

  InboundShipmentHeader = Struct.new(:shipment_name, :ship_from_address, :destination_fulfillment_center_id, :shipment_status, :label_prep_preference)

  # ship from address
  # return Address structus
  def ship_from_address
    @setting = Setting.instance
    ship_from_address = Address.new(
        @setting.address_name,
        @setting.address_line1,
        @setting.address_city,
        @setting.address_state,
        @setting.address_zip_code,
        @setting.address_country
    )
    ship_from_address
  end

end