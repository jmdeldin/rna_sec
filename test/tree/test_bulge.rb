require_relative 'test_helper'

class TestBulge < MiniTest::Unit::TestCase

  def setup
    @bases = [ :u, :u, :c, :u, :a ].map.with_index do |x, i|
      RnaSec::Tree::Base.new(i + 1, x)
    end
    @bulge = RnaSec::Tree::Bulge.new(@bases)
  end

  def test_size
    assert_equal @bases.size, @bulge.size
  end

  def test_to_vienna
    assert_equal 'RnaSec::Tree::Bulge<U1-A5>(.....)', @bulge.to_vienna()
  end

  def test_get_child_positions
    assert_equal [1, 2, 3, 4, 5], @bulge.get_child_positions()
  end

end

