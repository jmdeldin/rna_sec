require_relative 'test_helper'

class TestBase < MiniTest::Unit::TestCase

  def setup
    @b = RnaSec::Tree::Base.new(3, :c)
  end

  def test_new
    assert_instance_of RnaSec::Tree::Base, @b
  end

  def test_new_should_fail_on_floats
    assert_raises ArgumentError do
      RnaSec::Tree::Base.new(3.0, :c)
    end
  end

  def test_new_should_fail_on_strings
    assert_raises ArgumentError do
      RnaSec::Tree::Base.new(3, 'c')
    end
  end

  def test_idx
    assert_equal 3, @b.idx
  end

  def test_nuc
    assert_equal :c, @b.nuc
  end

  def test_to_vienna
    assert_equal '.', @b.to_vienna
  end

end

