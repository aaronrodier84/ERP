class CreateProductZoneAvailability < ActiveRecord::Migration
  def change
    create_table :product_zone_availabilities do |t|
      t.references :product
      t.references :zone
    end

    add_index :product_zone_availabilities, :product_id
    add_index :product_zone_availabilities, :zone_id
  end
end
