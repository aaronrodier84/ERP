class ZoneWorkflow
  def initialize(available_zones = Zone.all)
    @zones = available_zones.sort_by(&:production_order)
  end

  def next_zone(zone)
    current_position = zone.production_order
    zones.detect { |z| z.production_order == current_position + 1 }
  end

  def previous_zone(zone)
    current_position = zone.production_order
    zones.detect { |z| z.production_order == current_position - 1 }
  end

  private 
  attr_reader :zones
end
