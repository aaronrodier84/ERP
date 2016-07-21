# frozen_string_literal: true
def find_material_tr(material)
  find("tr[data-material-id='#{material.id}']")
end
