require_relative 'test_helper'

class TestRules < MiniTest::Unit::TestCase

  def setup
    @part_of_bp = RnaSec::CtParser::Record.from_array(%w[ 17 G 16 18 46 17 ])
  end

  def test_looking_at_part_of_a_base_pair
    rule = RnaSec::CtParser::Rules.new(@part_of_bp, nil, [])

    assert_equal true, rule.base_pair_part?
    assert_equal false, rule.base_pair?
  end

  def test_just_saw_a_base_pair
    last = RnaSec::Tree::Base.new(46, :c)
    rule = RnaSec::CtParser::Rules.new(@part_of_bp, last, [])

    assert_equal true, rule.base_pair?
  end

  def test_just_saw_a_bulge
    # LAST BP: BP(G14-C49)
    # BASES:   B(G15)
    # CURRENT: G17-?46
    last = RnaSec::Tree::BasePair.new(
      RnaSec::Tree::Base.new(14, :g),
      RnaSec::Tree::Base.new(49, :c)
    )
    bases = [ RnaSec::Tree::Base.new(15, :g) ]
    rule  = RnaSec::CtParser::Rules.new(@part_of_bp, last, bases)

    assert_equal true, rule.bulge?, 'Should have found a bulge'
    assert_equal false, rule.hairpin?, 'Should NOT be a hairpin'
    assert_equal false, rule.internal_loop?, 'Should NOT be an interior loop'
    assert_equal false, rule.single?, 'Should NOT be a SS nuc'
    assert_equal true, rule.base_pair_part?, 'Should be part of a base pair'
  end

  def test_just_saw_a_hairpin
    last = RnaSec::Tree::BasePair.new(
      RnaSec::Tree::Base.new(3, :c),
      RnaSec::Tree::Base.new(10, :g)
    )
    i = 3
    basess = %w[a u u a c g].map { |x| 
      RnaSec::Tree::Base.new(i+=1, x.to_sym)
    }
    cur = RnaSec::CtParser::Record.from_array(
      %w[10	G	9	11	3	10]
    )

    rule = RnaSec::CtParser::Rules.new(cur, last, basess)

    assert_equal true, rule.hairpin?, 'Should have found a hairpin'
    assert_equal false, rule.bulge?, 'Should NOT be a bulge'
    assert_equal true, rule.base_pair_part?, 'Should be a base pair'
    assert_equal false, rule.internal_loop?, 'Should not be an interior loop'
  end

  def test_current_base_is_single_stranded
    rec = RnaSec::CtParser::Record.from_array(
      %w[1	G	0	1	0	1]
    )
    rule = RnaSec::CtParser::Rules.new(rec, nil, [])

    assert_equal true, rule.single?
    assert_equal false, rule.hairpin?
    assert_equal false, rule.bulge?
    assert_equal false, rule.internal_loop?
  end

  def test_internal_loop?
    last = RnaSec::Tree::BasePair.new(
      RnaSec::Tree::Base.new(1, :g),
      RnaSec::Tree::Base.new(12, :c)
    )
    cur = RnaSec::CtParser::Record.from_array(
      %w[2	G	1	3	11	2]
    )
    rule = RnaSec::CtParser::Rules.new(cur, last, [])

    assert_equal true, rule.internal_loop?
    assert_equal false, rule.hairpin?
    assert_equal false, rule.base_pair?
    assert_equal true, rule.base_pair_part?
  end

end

