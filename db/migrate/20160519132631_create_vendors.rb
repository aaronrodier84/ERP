class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string    :name,   null: false
      t.string    :contact_name
      t.string    :phone
      t.string    :contact_email
      t.string    :contact_fax
      t.string    :order_email
      t.string    :order_fax
      t.string    :tags
      t.string    :address
      t.text      :notes

      t.timestamps null: false
    end
  end
end
