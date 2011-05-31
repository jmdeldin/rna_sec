require_relative 'test_helper'

class TestRoot < MiniTest::Unit::TestCase

  def test_new
    r = RnaSec::Tree::Root.new()
  end

  def test_to_vienna
    r = RnaSec::Tree::Root.new()
    assert_equal 'RnaSec::Tree::Root', r.to_vienna

    r.children = [ 
      RnaSec::Tree::Base.new(1, :c),
      RnaSec::Tree::Base.new(2, :g),
    ]

    assert_equal 'RnaSec::Tree::Root(..)', r.to_vienna
  end

end

