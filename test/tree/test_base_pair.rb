require_relative 'test_helper'

class TestBasePair < MiniTest::Unit::TestCase

  def setup
    @b5 = RnaSec::Tree::Base.new(1, :g)
    @b3 = RnaSec::Tree::Base.new(11, :c)
    @bp = RnaSec::Tree::BasePair.new(@b5, @b3)
  end

  def test_five_idx
    assert_equal @b5.idx, @bp.five_idx
  end

  def test_five_nuc
    assert_equal @b5.nuc, @bp.five_nuc
  end

  def test_idx
    assert_equal @bp.five_idx, @bp.idx
  end

  def test_three_idx
    assert_equal @b3.idx, @bp.three_idx
  end

  def test_three_nuc
    assert_equal @b3.nuc, @bp.three_nuc
  end

  def test_to_vienna
    assert_equal 'RnaSec::Tree::BasePair<G1-C11>', @bp.to_vienna
  end

end
