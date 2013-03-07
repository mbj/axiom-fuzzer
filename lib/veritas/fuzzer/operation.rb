module Veritas
  class Fuzzer
    # Abstract base class for fuzzing operations
    class Operation
      include AbstractType, Adamantium::Flat, Concord.new(:relation, :level)

      def self.next(*args)
        fuzzer = FUZZERS.sample
        fuzzer.new(*args).operation
      end
      
      def attributes
        relation.header.to_a
      end
      memoize :attributes

      def random_attributes
        attributes.sample(rand(attributes.size))
      end
      memoize :random_attributes

      def random_attribute
        attributes.sample
      end
      memoize :random_attribute

      abstract_method :operation

      class Noop < self
        def operation; end
      end

      class Extend < self
        def operation
          attribute = random_attribute
          return unless attribute.kind_of?(Veritas::Attribute::Integer)
          operator = [ :*, :%, :+, :-].sample
          if operator == :%
            operand = [1, 2, -1].sample
          else
            operand = [1, 2, 0, -1].sample
          end
          [ :extend, [], proc { |r| r.add(:"#{attribute.name}_#{level}", r.send(attribute.name).send(operator, operand)) } ]
        end
      end

      class Project < self

        def method
          [ :project, :remove ].sample
        end

        def operation
          attributes = random_attributes
          [ method, [ attributes ] ] if attributes.any?
        end

      end

      class Restriction < self
        def operation
          predicate = attributes.reduce(Veritas::Function::Proposition::Tautology.new) do |predicate, attribute|
            function = [ :eq, :ne, :gt, :gte, :lt, :lte ].sample
            value    = relation.map { |tuple| tuple[attribute] }.sample
            predicate.and(attribute.send(function, value))
          end
       
          [ :restrict, [], proc { predicate } ]
        end
      end

      class Binary < self

        def method
          [ :join, :product, :union, :intersect, :difference ].sample
        end

        def operation
          other_method, other_args, other_block = Operation.next(relation, level)
          return unless other_method
          right = relation.send(other_method, *other_args, &other_block) 
          [ :join, [ right ] ]
        end

      end
      
      FUZZERS = [
        Noop,
        Extend,
        Project,
        Restriction,
        Binary
      ]
    end
  end
end
