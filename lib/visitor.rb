require 'veritas'
require 'veritas-optimizer'
require 'graphviz'

include Veritas

class String
  def demodulize
    self[/[^:]+\z/]
  end
end

module Veritas
  module Visitor
    class Dot
      def self.dispatch
        @dispatch ||= {}
      end

      def initialize
        @graph = GraphViz.new(:G, :type => :digraph)
      end

      def accept(object, file='visitor.png')
        visit object
        to_dot(file)
      end

    private

      def visit(object)
        object.class.ancestors.each do |mod|
          method = "visit_#{mod.name.gsub('::', '_')}"
          return send(method, object) if respond_to?(method, true)
        end

        raise NoMethodError, "No visitor for #{object.class.name}"
      end

      def visit_Veritas_Operation_Unary(unary)
        operand = unary.operand
        node = @graph.add_node(unary.object_id.to_s, :label => unary.class.name.demodulize, :shape => 'rectangle')
        @graph.add_edge(visit(operand), node)
        node
      end

      def visit_Veritas_Operation_Binary(binary)
        left, right = binary.left, binary.right
        node = @graph.add_node(binary.object_id.to_s, :label => binary.class.name.demodulize, :shape => 'diamond')
        @graph.add_edge(visit(left),  node)
        @graph.add_edge(visit(right), node)
        node
      end

      def visit_Veritas_Algebra_Restriction(restriction)
        node = visit_Veritas_Operation_Unary(restriction)
        @graph.add_edge(visit(restriction.predicate), node)
        node
      end

      def visit_Veritas_Algebra_Projection(projection)
        node = visit_Veritas_Operation_Unary(projection)
        node.label = "{ #{projection.class.name.demodulize} | #{projection.header.map { |attribute| "#{attribute.name}: #{attribute.class.name.demodulize}" }.join('|')} }"
        node.shape = 'record'
        node
      end

      def visit_Veritas_Algebra_Rename(rename)
        node = visit_Veritas_Operation_Unary(rename)
        node.label = "{ #{rename.class.name.demodulize} | #{rename.aliases.map { |k,v| "#{k.name} to #{v.name}" }.join(' | ')} }"
        node.shape = 'record'
        node
      end

      def visit_Veritas_Attribute(attribute)
        @graph.add_node(attribute.object_id.to_s, :label => "#{attribute.name}: #{attribute.class.name.demodulize}", :shape => 'record')
      end

      def visit_Veritas_Relation(relation)
        @graph.add_node(
          relation.object_id.to_s,
          :label => "{ #{relation.class.name.demodulize} | #{relation.header.map { |attribute| "#{attribute.name}: #{attribute.class.name.demodulize}" }.join(' | ')} }",
          :shape => 'record'
        )
      end

      def visit_Object(object)
        @graph.add_node(object.object_id.to_s, :label => object.inspect, :shape => 'rectangle')
      end

      def to_dot(file='visitor.png')
        @graph.output('png' => file)
      end
    end
  end
end
