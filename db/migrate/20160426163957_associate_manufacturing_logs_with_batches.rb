class AssociateManufacturingLogsWithBatches < ActiveRecord::Migration
  def change
    remove_column :manufacturing_logs, :user_id
    remove_column :manufacturing_logs, :quantity
    add_column :manufacturing_logs, :batch_id, :integer
  end
end
