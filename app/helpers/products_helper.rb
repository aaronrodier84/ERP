module ProductsHelper
  def active_zone_class(zone, current_zone)
    zone.slug == current_zone.slug ? 'active' : ''
  end

  def days_of_cover(count)
    content_tag(:span, count)
  end

end
