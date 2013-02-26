require 'spec_helper'

describe Veritas::Fuzzer::Sexp, '.visit' do
  let(:object) { described_class }

  subject { object.visit(relation) }

  let(:header)        { Veritas::Relation::Header.coerce([[:foo, Integer]]) }
  let(:base_relation) { Veritas::Relation::Base.new(:name, header)          }

  let(:sorted_base_relation) { base_relation.sort_by { |r| [r.foo.asc] } }

  let(:other_header)        { Veritas::Relation::Header.coerce([[:bar, Integer]]) }
  let(:other_base_relation) { Veritas::Relation::Base.new(:other, other_header)   }

  def self.expect_sexp
    it 'should return correct sexp' do
      should eql(yield)
    end
  end

  context 'with base relation' do
    let(:relation) { base_relation }

    expect_sexp do
      [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ]
    end
  end

  context 'order' do
    let(:relation) { sorted_base_relation }

    expect_sexp do
      [ :order,
        [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ],
        [[ :asc, [ :attr, :foo ] ]]
      ]
    end
  end

  context 'offset' do
    let(:relation) { sorted_base_relation.drop(2) }

    expect_sexp do
      [
        :offset,
        [ :order,
          [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ],
          [[ :asc, [ :attr, :foo ] ]]
        ],
        2
      ]
    end
  end

  context 'limit' do
    let(:relation) { sorted_base_relation.take(2) }

    expect_sexp do
      [
        :limit,
        [ :order,
          [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ],
          [[ :asc, [ :attr, :foo ] ]]
        ],
        2
      ]
    end
  end

  context 'restriction' do
    let(:relation) { base_relation.restrict { |r| r.foo.eq('bar') } }

    expect_sexp do
      [ :restrict,
        [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ],
        [ :eql, [ :attr, :foo ] , 'bar' ]
      ]
    end
  end

  context 'product' do
    let(:relation) { base_relation.product(other_base_relation) }

    expect_sexp do
      [ :product,
        [ :base, 'name',  [ [ :foo, Veritas::Attribute::Integer ] ] ],
        [ :base, 'other', [ [ :bar, Veritas::Attribute::Integer ] ] ]
      ]
    end
  end

  context 'join' do
    let(:relation) { base_relation.join(base_relation) }

    expect_sexp do
      [ :join,
        [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ],
        [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ]
      ]
    end
  end

  context 'projection' do
    let(:relation) { base_relation.project([:foo]) }

    expect_sexp do
      [ :project,
        [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ],
        [ [ :attr, :foo ] ]
      ]
    end
  end

  context 'extension' do
    context 'with plain attribute' do
      let(:relation) { base_relation.extend { |r| r.add(:bar, r.foo) } }

      expect_sexp do
        [ :extend,
          [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ],
          [
            [ :bar, [ :attr, :foo ] ]
          ]
        ]
      end
    
    end

    context 'with multiplication' do
      let(:relation) { base_relation.extend { |r| r.add(:bar, r.foo * 2) } }

      expect_sexp do
        [ :extend,
          [ :base, 'name', [ [ :foo, Veritas::Attribute::Integer ] ] ],
          [
            [ :bar, [ :mul, [ :attr, :foo ], 2 ] ]
          ]
        ]
      end
    
    end
  end
end
