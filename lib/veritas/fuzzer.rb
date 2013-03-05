require 'veritas'
require 'veritas-sexp'
require 'terminal-table'
require 'diffy'
require 'pp'

module Veritas
  # Fuzzer namespace
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

    # Run fuzzer loop
    #
    # @reutrn [undefined]
    #
    # @api private
    #
    def run
      loop do
        run_stack
      end
    end

  private

    def equal_keys?(relations, left, right)
      return true if left < right
      left, right = relations.values_at(left, right)
      left == right
    end

    def assert_equal_key(relations, left_key, right_key)
      if equal_keys?(relations, left_key, right_key) 
        return
      end
   
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
        assert_equal_key(relations, left_key, right_key)
      end
    end

    def run_stack
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

            method, args, block = Operation.next(gateway, stack.length) if relation.any?

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

require 'veritas/fuzzer/operation'
