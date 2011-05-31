module RnaSec::CtParser

  # Represents the rules governing a given {Record} and environment.
  #
  # Use this class to determine what secondary structure a given record is.
  #
  # @see Record
  #
  class Rules

    # @param [Record] record
    # @param [RnaSec::Tree::BasePair] last Last Base/BP seen
    # @param [RnaSec::Tree::Bases[]] bases Array of bases
    #
    def initialize(record, last, bases = [])
      fail(ArgumentError, 'Record required') unless record.is_a? Record
      fail(ArgumentError, 'RnaSec::Tree::Bases must be an array') unless bases.is_a? Array

      @cur   = record
      @last  = last
      @bases = bases
    end

    # Determines if we are looking at *part* of a base pair.
    #
    # This is useful in determining whether we just saw a bulge or a hairpin.
    #
    # We'll know if we're looking at part of a base pair if the
    # <tt>pair_idx</tt> is a non-zero value.
    #
    # @return [Boolean]
    #
    def base_pair_part?
      @cur.pair_idx != 0
    end

    # Determines if we have the necessary components to form a base pair.
    #
    # We can form a base pair if
    #
    # 1. The last element was a Base, i.e.,
    #      @last == RnaSec::Tree::Base(i, nuc)
    #
    # 2. The current pair index matches the last base's index, i.e.,
    #      @cur.pair_idx == @last.idx
    #
    # @return [Boolean]
    #
    def base_pair?
      !@last.nil? &&
        @last.is_a?(RnaSec::Tree::Base) &&
        @cur.pair_idx == @last.idx
    end

    # Determines if we can form a bulge with the current environment.
    #
    # We cannot tell if we're in a bulge while looping through records,
    # but we can tell if we've seen one when:
    #
    # 1. It is not a hairpin.
    #
    # 2. The current record is part of a base pair.
    #
    # 3. There are bases in the <tt>@bases</tt> array.
    #
    # @return [Boolean]
    def bulge?
      !hairpin? && !internal_loop? && base_pair_part? && @bases.any?
    end

    # Determines if we can form a hairpin with the current environment.
    #
    # We can form a hairpin if:
    #
    # 1. The last node is a base pair.
    #
    # 2. The current node's 5' index (<tt>@cur.idx</tt>) corresponds to the
    #    last nodes 3' index.
    #
    # 3. There are single-stranded bases on the stack.
    #
    # @return [Boolean]
    #
    def hairpin?
      return false unless @last.is_a?(RnaSec::Tree::BasePair)
      return false unless @last.three_idx == @cur.idx
      return false unless @bases.any?

      # ensure all bases are single-stranded
      @bases.each { |b| return false unless b.is_a?(RnaSec::Tree::Base) }
      true
    end

    # Determines if we are looking at a single stranded base.
    #
    # This is simply a record with a 0 in the pair column.
    #
    # @return [Boolean]
    #
    def single?
      @cur.pair_idx == 0
    end

    # Determines if we can form an internal loop.
    #
    # We know we can form an internal loop if these conditions are met:
    #
    # 1. The last element is a base pair.
    #
    # 2. The last element's 5' index is the one less than the current
    #    element's index.
    #      @last.five_idx == @cur.idx - 1
    #
    # 3. The current node is part of a base pair.
    #
    # 4. The node is not a hairpin.
    #
    # @return [Boolean]
    #
    def internal_loop?
      return false unless @last.is_a?(RnaSec::Tree::BasePair)
      return false unless @last.five_idx == @cur.idx - 1
      return false unless base_pair_part?
      return false if hairpin?
      true
    end

  end

end

