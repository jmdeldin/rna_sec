require_relative 'test_helper'

class TestInternalLoop < MiniTest::Unit::TestCase

  def setup
    @il = RnaSec::Tree::InternalLoop.new(
      RnaSec::Tree::BasePair.new(
        RnaSec::Tree::Base.new(1, :g),
        RnaSec::Tree::Base.new(8, :c),
      )
    )
  end

  def test_to_vienna
    assert_equal 'RnaSec::Tree::InternalLoop<G1-C8>', @il.to_vienna()
  end

end

