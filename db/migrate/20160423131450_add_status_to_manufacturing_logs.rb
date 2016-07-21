class AddStatusToManufacturingLogs < ActiveRecord::Migration
  def change
    add_column :manufacturing_logs, :status, :integer, default: 10
  end
end
