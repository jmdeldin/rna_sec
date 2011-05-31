require_relative 'test_helper'

class TestParser < MiniTest::Unit::TestCase

  def setup
    @fn = get_fixture('mbe1a.ct', __FILE__)
  end

  def test_get_records
    recs  = RnaSec::CtParser::Parser.get_records(@fn)
    types = recs.map { |x| x.class }.uniq

    assert_equal 1, types.size
    assert_equal RnaSec::CtParser::Record, types.first
  end

end

