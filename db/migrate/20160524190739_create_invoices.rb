class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :invoice_number
      t.float :total
      t.datetime :due_date
      t.integer :vendor_id

      t.timestamps null: false
    end
  end
end
