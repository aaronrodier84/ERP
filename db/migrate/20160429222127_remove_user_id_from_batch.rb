class RemoveUserIdFromBatch < ActiveRecord::Migration
  def change
    remove_column :batches, :user_id
  end
end
