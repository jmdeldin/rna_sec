require 'test/unit'
require_relative '../lib/hairpin'
require_relative '../lib/base'
require_relative '../lib/tree'

module RnaSec
  class TestNode < Test::Unit::TestCase

    # ensure to_vienna can handle nested hairpins
    # seq: uaagcuguacguua
    # fmt: .(.(...)....).
    def test_to_vienna
      root = Tree.new(:key1 => Base.new(:u), :key2 => Base.new(:a))

      # no children
      assert_equal '..', root.to_vienna, 'Incorrect Vienna (layer 0)'

      # 1st layer of children
      first = Node.new(
        :key1 => Hairpin.new(:a, :start),
        :key2 => Hairpin.new(:u, :end),
      )
      root.children << first

      assert_equal '.().', root.to_vienna, 'Incorrect Vienna (layer 1)'

      # 2nd layer of children
      first.children << Node.new(:key1 => Base.new(:a));
      second = Node.new(
        :key1 => Hairpin.new(:g, :start),
        :key2 => Hairpin.new(:u, :end),
      )
      first.children << second
      [:a, :c, :g, :u].each do |x|
        first.children << Node.new(:key1 => Base.new(x))
      end

      assert_equal '.(.()....).', root.to_vienna, 'Incorrect Vienna (layer 2)'

      # 3rd layer of children (3 nodes)
      second.children = [:c, :u, :g].map { |x| Node.new(:key1 => Base.new(x)) }
      assert_equal '.(.(...)....).', root.to_vienna, 'Incorrect Vienna (layer 3)'

      # TODO: refactor this method into a fixture so test_to_sequence does not
      #       depend on it.
      root
    end

    # test tree->sequence
    # seq: uaagcuguacguua
    # fmt: .(.(...)....).
    def test_to_sequence
      # just use the tree built in the vienna test
      tree = test_to_vienna
      assert_equal 'uaagcuguacguua', tree.to_sequence, 'Sequence differs'
    end
  end
end

