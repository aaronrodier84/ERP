class CreateManufacturingLogsUsersTable < ActiveRecord::Migration
  def change
    create_table :manufacturing_logs_users do |t|
      t.integer :manufacturing_log_id  
      t.integer :user_id  
    end
  end
end
