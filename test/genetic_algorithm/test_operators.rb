require_relative 'test_helper'

class TestOperators < MiniTest::Unit::TestCase

  def setup
    @parent = RnaSec::Tree::InternalLoop.new(
      RnaSec::Tree::BasePair.new(
        RnaSec::Tree::Base.new(0, :g),
        RnaSec::Tree::Base.new(8, :c)
      )
    )
    @tribulge = RnaSec::Tree::Bulge.new([
      RnaSec::Tree::Base.new(4, :g),
      RnaSec::Tree::Base.new(5, :c),
      RnaSec::Tree::Base.new(6, :g),
    ])
  end

  def test_insert_bulge_into_bulge
    to_insert = RnaSec::Tree::Bulge.new([
      RnaSec::Tree::Base.new(1, :c),
      RnaSec::Tree::Base.new(2, :g),
      RnaSec::Tree::Base.new(3, :c),
    ])

    @parent << @tribulge

    pos = 1
    mutated = RnaSec::GeneticAlgorithm::Operators.splice!(
      to_insert,
      @tribulge,
      pos
    )

    exp = [
    'RnaSec::Tree::InternalLoop<G0-C8>(',
      'RnaSec::Tree::Bulge<G4-G4>(.), ',
      'RnaSec::Tree::Bulge<C1-C3>(...), ',
      'RnaSec::Tree::Bulge<C5-G6>(..)',
    ')'
    ].join()

    exp_arr = [0, 8, [4, 1, 2, 3, 5, 6]]

    assert_equal @parent.class, mutated.class, 'Should not have changed the parent class'
    assert_equal exp, mutated.to_vienna(), 'Vienna is incorrect'
    assert_equal exp_arr, @parent.get_child_positions(), 'Wrong order for nt indexes'
    assert_equal 4, @parent.find(4).children.first.idx, 'Existing bases should not be lost'
    assert_equal 3, @parent.children.size, 'Two bulges should have become three'
    assert_equal @parent.object_id, @parent.find(1).parent().object_id, 'Parents should have been updated on the spliced-in structure'
    assert_equal @parent.object_id, @parent.find(1).parent().object_id, 'Parents should have been updated on the spliced-in structure'
  end

  def test_insert_bulge_at_extremity
    to_insert = RnaSec::Tree::Bulge.new([
      RnaSec::Tree::Base.new(1, :c),
      RnaSec::Tree::Base.new(2, :g),
      RnaSec::Tree::Base.new(3, :c),
    ])

    @parent << @tribulge

    pos = 0
    mutated = RnaSec::GeneticAlgorithm::Operators.splice!(
      to_insert,
      @tribulge,
      pos
    )

    exp = [
    'RnaSec::Tree::InternalLoop<G0-C8>(',
      'RnaSec::Tree::Bulge<C1-C3>(...), ',
      'RnaSec::Tree::Bulge<G4-G6>(...)',
    ')'
    ].join()

    exp_arr = [0, 8, [1, 2, 3, 4, 5, 6]]

    assert_equal @parent.class, mutated.class, 'Should not have changed the parent class'
    assert_equal exp, mutated.to_vienna(), 'Vienna is incorrect'
    assert_equal exp_arr, @parent.get_child_positions(), 'Wrong order for nt indexes'
    assert_equal 4, @parent.find(4).children.first.idx, 'Existing bases should not be lost'
    assert_equal 2, @parent.children.size, 'Bulge should not have been split'
    assert_equal @parent.object_id, @parent.find(1).parent().object_id, 'Parents should have been updated on the spliced-in structure'
    assert_equal @parent.object_id, @parent.find(1).parent().object_id, 'Parents should have been updated on the spliced-in structure'
  end

  def test_insert_hairpin_into_bulge
    hp = RnaSec::Tree::Hairpin.new(
      RnaSec::Tree::BasePair.new(
        RnaSec::Tree::Base.new(91, :c),
        RnaSec::Tree::Base.new(97, :g)
      )
    )
    i = 91;
    bases = [:c, :g, :u, :a, :c].map { |x| i+=1; RnaSec::Tree::Base.new(i, x) }
    hp.children = bases

    @parent << @tribulge

    pos = 1
    mutated = RnaSec::GeneticAlgorithm::Operators.splice!(
      hp,
      @tribulge,
      pos
    )
    exp = [
      'RnaSec::Tree::InternalLoop<G0-C8>(',
        'RnaSec::Tree::Bulge<G4-G4>(.), ',
        'RnaSec::Tree::Hairpin<C91-G97>(.....), ',
        'RnaSec::Tree::Bulge<C5-G6>(..)',
      ')'
    ].join()
    exp_arr = [0, 8, [4, 91, 97, [92, 93, 94, 95, 96], 5, 6]]

    assert_equal exp, @parent.to_vienna()
    assert_equal exp_arr, @parent.get_child_positions()
    assert_equal @parent.object_id, hp.parent().object_id
    assert_equal 3, @parent.children.size
  end

end

