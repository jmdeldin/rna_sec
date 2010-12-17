require 'test/unit'
require_relative '../lib/fasta_file'
require_relative '../lib/rna_fold'

class TestRnaFold < Test::Unit::TestCase
  def setup
    fn = 'test/fixtures/fasta.txt'
    @entries = RnaSec::FastaFile.new(fn)
  end

  def test_sequence
    seq = 'CCCCCCGGGGGG'
    r = RnaSec::RnaFold.new(seq)
    assert_equal '((((....))))', r.results, 'Invalid results'
  end

  def test_empty_sequence
    r = RnaSec::RnaFold.new('')
    assert_raise(RuntimeError) do
      r.results
    end
  end

end

