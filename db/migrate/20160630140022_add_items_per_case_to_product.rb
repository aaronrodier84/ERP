# frozen_string_literal: true
class AddItemsPerCaseToProduct < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.integer :items_per_case, null: false, default: 0
    end
  end
end
