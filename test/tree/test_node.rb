require_relative 'test_helper'

class TestNode < MiniTest::Unit::TestCase

  def test_new_should_fail
    assert_raises NotImplementedError do
      RnaSec::Tree::Node.new
    end
  end

end

