module AssertDifferences
  def assert_differences(expression_hash, message = nil, &block)
    binding = block.send(:binding)
    before = expression_hash.map do |expression, _|
      eval(expression, binding) 
    end

    yield

    expression_hash.each_with_index do |pair, index|
      expression, difference = pair
      error = "#{expression.inspect} didn't change by #{difference}"
      error = "#{message}\n#{error}" if message
      assert_equal(before[index] + difference, eval(expression, binding), error)
    end
  end

  def assert_no_differences(expressions, message = nil, &block)
    binding = block.send(:binding)
    before = expressions.map { |exp| eval(exp, binding)}

    yield

    expressions.each_with_index do |expression, index|
      error = "#{expression.inspect} was changed when expecting no change"
      error = "#{message}\n#{error}" if message
      assert_equal before[index], eval(expression, binding), error
    end
  end
end

class ActiveSupport::TestCase
  include AssertDifferences
end

