class ShipmentPlansResult < Result
  attr_reader :entities, :errors

  def initialize(entities, success, errors)
    @entities = entities
    @success = success
    @errors = errors
  end

  def success?
    success
  end

  private
  attr_reader :success
end
