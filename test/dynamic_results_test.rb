require 'test/unit'
require 'veritas'
 
class DynamicResultsTest < Test::Unit::TestCase
  def test_dynamic_results
    g = generative_fib
    relation = Veritas::Relation.new([ [ :num, Integer ] ], )
    # does not load all values into memory
    divisible_by_5 = relation.restrict(lambda { |tuple| tuple[:num] % 5 == 0}).order([ relation[:num] ]).take(20)
    divisible_by_5.each { |v| p v }
  end

  protected

  def generative_fib
    Enumerator.new { |y|
      a = b = 1
      loop {
        y << a
        a, b = b, a + b
      }
    }
  end
end

