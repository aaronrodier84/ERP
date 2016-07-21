class RenameDateColumn < ActiveRecord::Migration
  def change
    rename_column :manufacturing_logs, :date, :completed_on
  end
end
