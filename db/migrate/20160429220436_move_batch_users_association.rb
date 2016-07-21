class MoveBatchUsersAssociation < ActiveRecord::Migration
  def change
    drop_table :manufacturing_logs_users

    create_table :batches_users do |t|
      t.integer :batch_id  
      t.integer :user_id  
    end
  end
end
