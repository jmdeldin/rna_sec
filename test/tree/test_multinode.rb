require_relative 'test_helper'

# TODO: Remove aliases after major refactoring
Base      = RnaSec::Tree::Base
BasePair  = RnaSec::Tree::BasePair
MultiNode = RnaSec::Tree::MultiNode

class TestMultiNode < MiniTest::Unit::TestCase

  def setup
    @bases = [
      BasePair.new(Base.new(2, :g), Base.new(3, :c)),
      BasePair.new(Base.new(4, :g), Base.new(5, :c)),
    ]
    @ends = BasePair.new(Base.new(1, :g), Base.new(6, :c))
    @m    = MultiNode.new(@ends, @bases)
  end

  def test_new_fails_with_nils
    assert_raises ArgumentError do
      MultiNode.new(nil, nil)
    end

    assert_raises ArgumentError do
      MultiNode.new(@ends, nil)
    end
  end

  def test_five_idx
    assert_equal @ends.five_idx, @m.five_idx
  end

  def test_five_nuc
    assert_equal @ends.five_nuc, @m.five_nuc
  end

  def test_idx
    assert_equal @m.five_idx, @m.idx
  end

  def test_three_idx
    assert_equal @ends.three_idx, @m.three_idx
  end

  def test_three_nuc
    assert_equal @ends.three_nuc, @m.three_nuc
  end

  def test_to_vienna
    exp = %w[
    RnaSec::Tree::MultiNode<G1-C6>(
        RnaSec::Tree::BasePair<G2-C3>
        RnaSec::Tree::BasePair<G4-C5>
    )
    ].join()
    assert_equal exp, @m.to_vienna
  end

  def test_get_bounds_on_multinode
    assert_equal [2, 5], @m.get_bounds()
  end

  def test_size
    assert_equal @bases.size, @m.size
  end

  def test_each
    @m.each do |c|
      assert_equal BasePair, c.class
    end
  end

  def test_clone_creates_new_references
    copy = @m.clone()

    @m.zip(copy) do |src, dest|
      assert src.object_id != dest.object_id
    end

    copy.children = []
    assert_equal @bases.size, @m.size
  end

  def test_get_child_positions_when_bps_for_children
    assert_equal [1, 6, [[2, 3], [4, 5]]], @m.get_child_positions()
  end

  def test_get_child_positions_when_bulge_is_child
    offset = 2 # bulge from 2-6
    bases = [:u, :u, :c, :u, :a].map.with_index { |x, i|
      RnaSec::Tree::Base.new(i + offset, x)
    }
    bulge = RnaSec::Tree::Bulge.new(bases)

    tree = MultiNode.new(BasePair.new(Base.new(1, :c), Base.new(7, :u)))
    tree.children << bulge

    assert_equal [1, 7, [2, 3, 4, 5, 6]], tree.get_child_positions()
  end

  def test_get_child_positions_when_children_are_not_nodes
    tree = MultiNode.new(BasePair.new(Base.new(1, :c), Base.new(7, :u)))
    tree.children = %w[ foo bar baz ]

    assert_raises RuntimeError do
      tree.get_child_positions()
    end
  end

  def test_find_shallow_fivep
    assert_equal @bases[0], @m.find(@bases[0].five_idx)
    assert_equal @bases[0].five_idx, @m.find(@bases[0].five_idx).five_idx
  end

  def test_find_shallow_threep
    assert_equal @bases[1], @m.find(@bases[1].three_idx)
    assert_equal @bases[1].three_idx, @m.find(@bases[1].three_idx).three_idx
  end

  def test_find_deep
    stack = [
      # root
      BasePair.new(Base.new(1, :g), Base.new(6, :c)),
      # subtree root
      BasePair.new(Base.new(2, :g), Base.new(7, :c)),
      BasePair.new(Base.new(3, :g), Base.new(4, :c)),
      BasePair.new(Base.new(5, :g), Base.new(6, :c)),
    ]
    subtree = MultiNode.new(stack[1], stack[2 .. -1])
    tree    = MultiNode.new(stack[0], [ subtree ])

    assert_equal subtree, tree.find(2)
    assert_equal stack.last, tree.find(6)
    assert_equal stack.last.three_idx, tree.find(6).three_idx
  end

  def test_find_returns_nil_on_nonexistant_index
    assert_equal nil, @m.find(20)
  end

  def test_prune_basepair
    copy = @m.clone()
    del  = copy.prune!(@bases.last.three_idx)

    assert_equal @bases.last.three_idx, del.three_idx
    assert_equal @bases.last.five_idx, del.five_idx
    assert_equal 1, copy.size
  end

  def test_prune_base_from_hairpin
    bases = [
      Base.new(2, :c),
      Base.new(3, :g),
      Base.new(4, :c)
    ]

    hp          = MultiNode.new(BasePair.new(Base.new(1, :g), Base.new(5, :c)))
    hp.children = bases.clone
    old         = bases.last
    del         = hp.prune!(bases.last.idx)

    assert_equal old, del
    assert_equal bases.size - 1, hp.size
  end

  def test_insert_base_into_hp
    # a slightly broken hairpin -- one that was just pruned
    src = MultiNode.new(BasePair.new(Base.new(1, :g), Base.new(5, :c)))
    src.insert(2, Base.new(2, :c))
    pruned = src.prune!(2)
    assert_equal :c, pruned.nuc

    src.insert(2, Base.new(2, :c))
    src.insert(4, Base.new(4, :u))
    src.insert(3, Base.new(3, :g))

    assert_equal :u, src.prune!(4).nuc
    assert_equal 2, src.children.size
  end

  def test_insert_out_of_order
    il = @m.clone()
    il.children = []

    # this will be the first node until we insert the next
    il.insert(@bases[1].five_idx, @bases[1])
    assert_equal @bases[1], il.children[0]

    # this will supplant the previous node
    il.insert(@bases[0].five_idx, @bases[0])
    assert_equal @bases[0], il.children[0]
    assert_equal @bases[1], il.children[1]
  end

end

