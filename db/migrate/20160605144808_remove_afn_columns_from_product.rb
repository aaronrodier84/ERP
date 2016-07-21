class RemoveAfnColumnsFromProduct < ActiveRecord::Migration
  def change
    remove_column :products, :afn_fulfillable_quantity, :integer, default: 0
    remove_column :products, :afn_reserved_quantity, :integer, default: 0
    remove_column :products, :afn_inbound_working_quantity, :integer, default: 0
    remove_column :products, :afn_inbound_shipped_quantity, :integer, default: 0
  end
end
