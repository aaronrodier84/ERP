# frozen_string_literal: true
module Generic
  module InPlaceEditableHelper
    # Provides in-place editable link
    # Usage example: in_place_editable product, :production_buffer_days, min: 0, class: 'xsmall'
    def in_place_editable(model, method, input_options = {})
      in_place_editable_inner(model, method, {}, input_options)
    end

    def in_place_editable_with_reload(model, method, input_options = {})
      in_place_editable_inner(model, method, { reload: true }, input_options)
    end

    protected

    def in_place_editable_inner(model, method, container_data, input_options)
      content_tag(:div, class: "js-in-place-editable", data: container_data) do
        link_text = model.send(method) || "N/A"
        link = link_to link_text, "#"
        form = bootstrap_form_for model do |f|
          f.number_field method, input_options
        end
        link + form
      end
    end
  end
end
