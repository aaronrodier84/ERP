class DropManufacturingLogs < ActiveRecord::Migration
  def change
    drop_table :manufacturing_logs
  end
end
