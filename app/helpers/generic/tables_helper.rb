module Generic::TablesHelper
  def index_table(css_classes='')
    content_tag :table, class: "table table-bordered index-table #{css_classes}" do
      yield
    end
  end
end
