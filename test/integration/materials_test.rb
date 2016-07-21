# frozen_string_literal: true
require 'test_helper'

class MaterialsTest < ActionDispatch::IntegrationTest
  describe 'index page - inventory quantity column' do
    let(:old_qty) { 111 }
    let(:material) { create :material, inventory_quantity: old_qty }

    it 'is in-place editable' do
      material
      new_qty = 222
      visit materials_path
      material_tr = material_tr(material)

      within material_tr do
        click_link old_qty
        input = find('input')
        assert_equal old_qty, input.value.to_i

        input.set new_qty # fill_in equivalent
        assert page.has_link? new_qty
      end

      # check the value has been updated on the backend
      assert_equal new_qty, material.reload.inventory_quantity
    end

    it 'processes validation' do
      material
      visit materials_path
      material_tr = material_tr(material)

      within material_tr do
        click_link old_qty
        input = find('input')
        error_message = accept_alert do
          input.set "-5000"
        end
        assert_match(/Error!/, error_message)
      end

      assert_equal old_qty, material.reload.inventory_quantity
    end
  end

  protected

  def material_tr(material)
    find("tr[data-material-id='#{material.id}']")
  end
end
