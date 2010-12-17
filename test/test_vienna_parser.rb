require 'test/unit'
require_relative '../lib/vienna_parser'

module RnaSec
  class TestViennaParser < Test::Unit::TestCase
    def test_parser
      seqs = 'UGGAAGAAGCUCUGGCAGCUUUUUAAGCGUUUAUAUAAGAGUUAUAUAUAUGCGCGUUCCA'
      fmt  = '.(((.((((((.....))))))....((((.((((((.......)))))).))))..))).'
      parser = ViennaParser.new(seqs, fmt)
      parsed = parser.parse.join('')
      assert_equal(parsed, fmt, 'Input == Output')
    end
  end
end

