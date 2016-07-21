module Generic::LinksHelper
  # Returns a link to the model if current user is permitted to view it;
  # Returns a text otherwise.
  def link_or_text(model, is_admin, link_text=nil)
    link_text ||= model.to_s
    if is_admin && block_given?
      link_to model do
        yield
      end
    elsif is_admin
      link_to link_text, model
    elsif block_given?
      yield
    else
      link_text
    end
  end
end
