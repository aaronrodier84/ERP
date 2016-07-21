# frozen_string_literal: true
require 'test_helper'

class BatchesEditTest < ActionDispatch::IntegrationTest
  let(:product) { create :product, items_per_case: 150 }
  let(:pack_zone) { create :zone, :pack }
  let(:batch) { create :batch, zone: pack_zone, product: product }

  it 'allows to add ingredients' do
    visit edit_batch_path(batch)

    item_quantity_field.set(750)
    fill_in "Notes", with: "asjhfsadf"
    assert_equal "5", case_quantity_field.value

    item_quantity_field.set(800)
    assert_equal "5.33", case_quantity_field.value

    case_quantity_field.set(4)
    assert_equal "600", item_quantity_field.value

    click_on "Save"
    assert page.has_content? "Batch successfully updated"
    assert_equal 600, batch.reload.quantity
  end

  protected

  def case_quantity_field
    find(".js-case-quantity")
  end

  def item_quantity_field
    find(".js-item-quantity")
  end
end
