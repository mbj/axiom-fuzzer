require 'veritas'
require 'veritas-sexp'
require 'terminal-table'
require 'diffy'
require 'pp'

module Veritas
  # Fuzzer, to be broken up in much smaller parts
  class Fuzzer
    include Composition.new(:gateway, :relation)

    # Run fuzzer
    #
    # @return [undefined]
    # 
    # @api private
    #
    def self.run(*args)
      new(*args).run
    end

    def run
      loop do
        run_with_timeout
      end
    end

  private

    def assert_equal_key(left_key, right_key)
      next if left_key < right_key
      left, right = relations.values_at(left_key, right_key)
      next if left == right
   
      left_table  = table(left.sort_by  { left.header  })
      right_table = table(right.sort_by { right.header })

      sexp = Veritas::Sexp::Generator.visit(relation)

      raise %W(
        Veritas-Relation:
        #{sexp.pretty_inspect}
        #{left_key} and #{right_key} are different:
        #{Diffy::Diff.new(left_table, right_table)}
      ).join("\n")
    end

    def assert_equality(relations, relation)
      relations.keys.permutation(2) do |(left_key, right_key)|
      end
    end

    def run
      stack = [ [ gateway, relation ] ]

      while element = stack.last
        begin
          Timeout.timeout(2) do
            gateway, relation = element

            relations = {
              :gateway_materialized  => gateway.materialize,
              :relation_materialized => relation.materialize,
            }

            assert_equality(relations, relation)

            method, args, block = next_operation(gateway, stack.length) if relation.any?

            if method.nil?
              stack.pop
            else
              stack << [
                gateway.send(method, *args, &block),
                relation.send(method, *args, &block),
              ]
            end
          end
        rescue Timeout::Error
          puts "timeout"
          break
        end

        puts stack.length

      end
    end

    def next_operation(relation, level)
      # TODO: break this up into separate classes for each mutation
      #       and then randomly select the mutator class.
      # TODO: add more operations
      method = [ 
        :project, 
        :remove, 
        :extend, 
        :join, 
        :product, 
    #   :union, 
    #   :intersect, 
    #   :difference, 
        :restrict, 
      ].sample

      header      = relation.header
      header_size = header.to_a.size
      attributes  = header.to_a.sample(rand(header_size))

      case method
      when nil
        nil  # do nothing
      when :extend
        attribute = attributes.sample
        return unless attribute.kind_of?(Veritas::Attribute::Integer)
        operator = [ :*, :%, :+, :-].sample
        if operator == :%
          operand = [1, 2, -1].sample
        else
          operand = [1, 2, 0, -1].sample
        end
        [ :extend, [], proc { |r| r.add(:"#{attribute.name}_#{level}", r.send(attribute.name).send(operator, operand)) } ]
      when :base
        [ :restrict, [], proc { Veritas::Function::Proposition::Tautology.new } ]
      when :project, :remove
        [ method, [ attributes ] ] if attributes.any?
      when :restrict
        predicate = attributes.reduce(Veritas::Function::Proposition::Tautology.new) do |predicate, attribute|
          function = [ :eq, :ne, :gt, :gte, :lt, :lte ].sample
          value    = relation.map { |tuple| tuple[attribute] }.sample
     
          predicate.and(attribute.send(function, value))
        end
     
        [ :restrict, [], proc { predicate } ]
      when :join, :product, :union, :intersect, :difference
        other_method, other_args, other_block = next_operation(relation, level)
        return unless other_method
        right = relation.send(other_method, *other_args, &other_block) 
        [ :join, [ right ] ]
      else
        raise "unhandled operation: #{method}"
      end
    end
 

    def table(relation)
      Terminal::Table.new do |table|
        table.headings = relation.header.map(&:name)
        table.rows     = relation.map(&:to_ary)
      end
    end
  end
end
