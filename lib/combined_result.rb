class CombinedResult < Result
  attr_reader :results

  def initialize(*results)
    @results = results
  end

  def success?
    results.all? { |res| res && res.success? }
  end

  def entity
    results.find { |res| !res.entity.nil?}&.entity
  end

  def errors
    results.flat_map(&:errors).compact
  end
end
