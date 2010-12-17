require 'test/unit'
require_relative '../lib/fasta_file'

class TestFastaFile < Test::Unit::TestCase
  def setup
    fn = 'test/fixtures/fasta.txt'
    @fasta = RnaSec::FastaFile.new(fn)
  end

  def test_entries
    @fasta.entries.each do |e|
      assert e[0] != '>', 'Header found'
    end
  end

  def test_clean
    @fasta.entries.each do |e|
      assert_nil e.match(/\s+/), "Space found"
    end
  end
end

