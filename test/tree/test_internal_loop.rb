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

  def test_traverse_parents
    il = RnaSec::Tree::InternalLoop.new(
      RnaSec::Tree::BasePair.new(
        RnaSec::Tree::Base.new(1, :g),
        RnaSec::Tree::Base.new(8, :c),
      )
    )

    child_il = RnaSec::Tree::InternalLoop.new(
        RnaSec::Tree::BasePair.new(
          RnaSec::Tree::Base.new(2, :g),
          RnaSec::Tree::Base.new(7, :c)
        )
    )

    child_il.children = [
      RnaSec::Tree::BasePair.new(
        RnaSec::Tree::Base.new(3, :g),
        RnaSec::Tree::Base.new(4, :c)
      )
    ]

    il << child_il

    assert_equal il.object_id, il.children[0].parent.object_id
    assert_equal child_il.object_id, child_il.children.first.parent.object_id
    assert_equal il.object_id, child_il.children[-1].parent.parent.object_id
  end

end

