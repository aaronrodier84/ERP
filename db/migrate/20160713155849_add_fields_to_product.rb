# frozen_string_literal: true
class AddFieldsToProduct < ActiveRecord::Migration
  def up
    change_table :products do |t|
      t.integer :production_buffer_days, null: false, default: 35
      t.integer :batch_min_quantity, null: false, default: 0
      t.integer :batch_max_quantity
    end

    change_table :zones do |t|
      t.remove :production_buffer_days
    end
  end

  def down
    change_table :zones do |t|
      t.integer :production_buffer_days, null: false, default: 30
    end

    change_table :products do |t|
      t.remove :production_buffer_days
      t.remove :batch_min_quantity
      t.remove :batch_max_quantity
    end
  end
end
