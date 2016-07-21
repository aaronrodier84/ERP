class TransactionResult < Result
  attr_reader :errors, :failed

  def initialize(success:, errors: [], failed: [] )
    @success = success
    @errors = errors
    @failed = failed
  end

  def success?
    success
  end

  def entity
    failed&.first
  end

  private
  attr_reader :success
end
