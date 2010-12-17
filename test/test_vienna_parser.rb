require 'test/unit'
require_relative '../lib/vienna_parser'

class TestViennaParser < Test::Unit::TestCase
  def test_simple_vienna
    seq = 'UA'
    fmt  = '..'
    parser = RnaSec::ViennaParser.new(seq, fmt)
    assert_equal '..', parser.parse.to_vienna, 'Vienna is incorrect'
  end

  def test_complex_vienna
    seq = 'UGGAAGAAGCUCUGGCAGCUUUUUAAGCGUUUAUAUAAGAGUUAUAUAUAUGCGCGUUCCA'
    fmt  = '.(((.((((((.....))))))....((((.((((((.......)))))).))))..))).'
    parser = RnaSec::ViennaParser.new(seq, fmt)
    parsed = parser.parse.to_vienna
    assert_equal fmt, parsed, 'Vienna is incorrect'
  end
end

