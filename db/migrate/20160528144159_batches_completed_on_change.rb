class BatchesCompletedOnChange < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.change :completed_on, :date
    end
  end
end
