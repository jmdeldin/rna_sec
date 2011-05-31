require_relative 'test_helper'

class TestRecord < MiniTest::Unit::TestCase

  def test_from_array
    arr = %w[1	C	0	2	6	1]
    rec = RnaSec::CtParser::Record.from_array(arr)

    assert_equal RnaSec::CtParser::Record, rec.class
    assert_equal arr[0].to_i, rec.idx
    assert_equal arr[1].downcase.to_sym, rec.nuc
    assert_equal arr[2].to_i, rec.five_idx
    assert_equal arr[3].to_i, rec.three_idx
    assert_equal arr[4].to_i, rec.pair_idx
  end

end

