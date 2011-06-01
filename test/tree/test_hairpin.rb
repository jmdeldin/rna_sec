require_relative 'test_helper'

class TestHairpin < MiniTest::Unit::TestCase

  def setup
    offset = 4
    @children = [:a, :u, :u, :a, :c, :g, ].map.with_index { |x, i|
      RnaSec::Tree::Base.new(i + offset, x)
    }

    @terminal = RnaSec::Tree::BasePair.new(
      RnaSec::Tree::Base.new(3, :c),
      RnaSec::Tree::Base.new(10, :g)
    )

    @hp = RnaSec::Tree::Hairpin.new(@terminal, @children)
  end

  def test_new
    assert_equal @terminal.five_idx, @hp.five_idx
    assert_equal @children, @hp.children
  end

  def test_get_child_positions
    assert_equal [3, 10, [4, 5, 6, 7, 8, 9]], @hp.get_child_positions()
  end

  def test_to_vienna
    assert_equal 'RnaSec::Tree::Hairpin<C3-G10>(......)', @hp.to_vienna
  end

end

