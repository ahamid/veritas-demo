require 'test/unit'
require 'veritas'
 
class DynamicResultsTest < Test::Unit::TestCase
  def test_dynamic_results
    g = generative_fib
    relation = Veritas::Relation.new([ [ :num, Integer ] ], g)
    # does not load all values into memory
    divisible_by_5 = relation.restrict(lambda { |tuple| tuple[:num] % 5 == 0}).take(20)
    divislbe_by_5.each { |v| p v }
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

