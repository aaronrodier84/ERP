module Generic::ApplicationHelper
  def new_vs_edit(action)
    action == 'new' ? "New" : "Update"
  end

  def nav_link(link_text, icon, link_path, controller)
    class_name = controller == params[:controller] ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_path do
        concat content_tag(:i, '', :class => "fa fa-w #{icon}")
        concat ' ' + link_text
      end
    end
  end

  def page_header
    content_tag :div, class: "row page-header" do
      content_tag :div, class: "col-lg-12" do
        content_tag :h2 do
          yield
        end
      end
    end
  end
end
