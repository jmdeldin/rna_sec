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

  def test_parse_hairpin
    hp = <<-EOF
      1	C	0	2	6	1
      2	C	1	3	0	2
      3	G	2	4	0	3
      4	C	3	5	0	4
      5	G	4	6	0	5
      6	G	5	0	1	6
    EOF
    hp   = heredoc_to_records(hp)
    tree = RnaSec::CtParser::Parser.parse(hp)

    assert_equal 1, tree.children.size, 'Tree should have 1 immediate child'
    assert_equal RnaSec::Tree::Hairpin, tree.children.first.class, 'First child should be an hairpin loop'

    # descend...
    immed_child = tree.children.first
    assert_equal RnaSec::Tree::Base, immed_child.children.map { |x| x.class }.uniq.first
  end

  def test_nested_internal_loop
    ct = <<-EOF
      1	G	0	2	12	1
      2	G	1	3	11	2
      3	C	2	4	10	3
      4	A	3	5	0	4
      5	U	4	6	0	5
      6	U	5	7	0	6
      7	A	6	8	0	7
      8	C	7	9	0	8
      9	G	8	10	0	9
      10	G	9	11	3	10
      11	C	10	12	2	11
      12	C	11	0	1	12
    EOF
    tree = RnaSec::CtParser::Parser.parse(heredoc_to_records(ct))

    assert_equal RnaSec::Tree::Root, tree.class, 'Should be a root'
    assert_equal 1, tree.children.size, 'Should have one child'
    assert_equal RnaSec::Tree::InternalLoop, tree.children.first.class, 'Only child should be an IL'
    assert_equal RnaSec::Tree::InternalLoop, tree.children.first.children.first.class, 'IL contains IL'
  end

  private

  def heredoc_to_records(s)
    s.gsub(/^\s+/, '').split(/\n/).map do |x|
      RnaSec::CtParser::Record.from_array( x.split(/\t/) )
    end
  end

end

