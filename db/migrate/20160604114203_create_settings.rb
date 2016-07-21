class CreateSettings < ActiveRecord::Migration
  def up
    create_table :settings do |t|
      t.string :aws_access_key_id
      t.string :aws_secret_key
      t.string :mws_marketplace_id
      t.string :mws_merchant_id

      t.string :address_name
      t.string :address_line1
      t.string :address_line2
      t.string :address_city
      t.string :address_state
      t.string :address_zip_code
      t.string :address_country

      t.timestamps
    end
  end

  def down
    drop_table :settings
  end
end
