require 'test/unit'
require 'veritas'
 
class DynamicResultsTest < Test::Unit::TestCase
  def test_dynamic_results
    g = generative_fib
    5.times { p g.next }
  end

  protected

  def generative_fib
    Enumerator.new { |b|
      history = [ ]
      while true do
        if history.empty?
          b.yield 0 
          history += [ 0, 1]
        else
          val = history[0] + history[1]
          history.shift
          history << val
          b.yield val
        end
      end
    }
  end
end

