require 'test_helper'
require 'graphviz'
require 'visitor'

class OptimizerTest < Test::Unit::TestCase
  def test_optimizer

    header = Relation::Header.new([ [ :id, Integer ], [ :name, String ] ])
    body   = [ [ 1, 'Dan Kubb' ], [ 2, 'John Doe' ], [ 3, 'Jane Doe' ] ].each

    left  = Relation.new(header, body)
    right = Relation.new(header, body)

    relation = left | right
    relation = relation & left
    relation = relation & right
    relation = relation - Relation::Empty.new(header)
    relation = relation | Relation::Empty.new(header)
    relation = relation * Relation.new([ [ :age, Integer ] ], [ [ 35 ] ])
    relation = relation.restrict { |r| r[:name].match(/Kubb/).inverse }.
                        restrict { |r| r[:name].eq('John Doe') }.
                        project([ :name ]).
                        rename(:name => :full_name)

    relation = relation.order(relation.header).take(2).reverse.order(relation.header)

    visitor = Visitor::Dot.new
    visitor.accept(relation, 'unoptimized.png')
    visitor.accept(relation.optimize, 'optimized.png')
  end

  protected

end
