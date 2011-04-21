require 'test/unit'
require 'veritas'

class VeritasTest < Test::Unit::TestCase
  SHAPES = [ 'square', 'triangle', 'circle', nil ]
  COLORS = [ 'red', 'green', 'blue', nil ]

  def test_materialized_records
    records = generate_records
    relation = Veritas::Relation.new(
      [
        [ :id, Integer ],
        [ :shape, String ],
        [ :color, String ],
        [ :price, Float ],
      ],
      records.enum_for(:each)
    );
   circles = relation.restrict(
               relation[:shape].match(/circle/i)
                 .and(relation[:price].gt(50))
                 .and(lambda { |tuple| tuple[:id] % 2 == 0 })) # custom modulo predicate -> only even ids
   p circles
   p circles.count
   circles.each { |c| p c }
  end

  protected

  def generate_records(n=100)
    records = []
    n.times do
      records << [
        rand(n),
        SHAPES[rand(SHAPES.length)],
        COLORS[rand(COLORS.length)],
        rand * n
      ]
    end
    records
  end
end
