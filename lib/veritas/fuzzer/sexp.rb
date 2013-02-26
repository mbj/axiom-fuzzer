module Veritas
  module Fuzzer
    module Sexp
      # Incomplete sexp formatter operation table
      REGISTRY = IceNine.deep_freeze( 
        Relation::Base                           => [ :base                                       ],
        Relation::Operation::Order               => [ :binary,    :order, :operand, :directions   ],
        Relation::Header                         => [ :collect                                    ],
        Relation::Operation::Order::DirectionSet => [ :collect                                    ],
        Relation::Operation::Order::Ascending    => [ :unary,     :asc,  :attribute               ],
        Relation::Operation::Order::Descending   => [ :unary,     :desc, :attribute               ],
        Relation::Operation::Limit               => [ :binary,    :limit, :operand, :limit        ],
        Relation::Operation::Offset              => [ :binary,    :offset, :operand, :offset      ],
        Algebra::Restriction                     => [ :binary,    :restrict, :operand, :predicate ],
        Algebra::Extension                       => [ :extend                                     ],
        Algebra::Projection                      => [ :binary,    :project, :operand, :header     ],
        Algebra::Join                            => [ :binary,    :join                           ],
        Algebra::Product                         => [ :binary,    :product                        ],
        Function::Predicate::Equality            => [ :binary,    :eql                            ],
        Function::Numeric::Absolute              => [ :binary,    :abs                            ],
        Function::Numeric::Addition              => [ :binary,    :add                            ],
        Function::Numeric::Division              => [ :binary,    :div                            ],
        Function::Numeric::Exponentiation        => [ :binary,    :exp                            ],
        Function::Numeric::Modulo                => [ :binary,    :mod                            ],
        Function::Numeric::Multiplication        => [ :binary,    :mul                            ],
        Function::Numeric::SquareRoot            => [ :unary,     :sqr                            ],
        Function::Numeric::Subtraction           => [ :binary,    :sub                            ],
        Function::Numeric::UnaryMinus            => [ :unary,     :unary_minus                    ],
        Function::Numeric::UnaryPlus             => [ :unary,     :unary_plus                     ],
        Attribute::String                        => [ :attribute                                  ],
        Attribute::Integer                       => [ :attribute                                  ]
      )

      def self.visit(relation)
        name, *options = REGISTRY.fetch(relation.class) { return relation }
        public_send(name, relation, *options)
      end

      def self.binary(relation, tag, left = :left, right = :right)
        [ tag, visit(relation.public_send(left)), visit(relation.public_send(right)) ]
      end

      def self.unary(relation, tag, operand = :operand)
        [ tag, visit(relation.public_send(operand)) ]
      end

      def self.collect(input)
        input.map do |item|
          visit(item)
        end
      end
      
      def self.extend(relation)
        [ :extend, visit(relation.operand), extensions(relation.extensions) ]
      end

      def self.extensions(hash)
        hash.map do |attribute, relation|
          [ attribute.name, visit(relation) ]
        end
      end

      def self.base(relation)
        [ :base, relation.name, base_header(relation.header) ]
      end

      def self.base_header(header)
        header.map do |attribute|
          base_attribute(attribute)
        end
      end

      def self.base_attribute(attribute)
        [ attribute.name, attribute.class ]
      end

      def self.attribute(attribute)
        [ :attr, attribute.name ]
      end
    end
  end
end
