module ZonesHelper
  def zone_label(zone)
    return nil unless zone
    content_tag :span, class: "zone-label #{zone_label_css_class(zone)}" do
      zone.name
    end
  end

  protected
    def zone_label_css_class(zone)
      "zone-#{zone.name.downcase}"
    end
end
