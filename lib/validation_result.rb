class ValidationResult
  attr_reader :params, :errors
  
  def initialize(params:, success:, errors:)
    @params = params
    @success = success
    @errors = errors
  end

  def success?
    success
  end
  
  def failure?
    !success
  end

  def result
    [self]
  end

  private
  attr_reader :success
end
