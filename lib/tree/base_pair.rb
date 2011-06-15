module RnaSec::Tree

  # Represents a base pairing between two nucleotides.
  #
  # @see Base
  #
  class BasePair < Node

    # TODO: It might be better to store the 5' and 3' objects instead,
    # but for now, inline their data for easier access.

    attr_reader :five_nuc
    attr_reader :five_idx
    alias :idx  :five_idx
    attr_reader :three_nuc
    attr_reader :three_idx

    attr_accessor :parent

    # @param [Base] five    5' end
    # @param [Base] three   3' end
    #
    def initialize(five, three)
      @five_nuc  = five.nuc
      @five_idx  = five.idx
      @three_nuc = three.nuc
      @three_idx = three.idx
      @parent    = nil
    end

    # Returns a nested array of the 5' and 3' indexes.
    #
    # @return (@five_idx, @three_idx)
    #
    def get_child_positions
      [ [@five_idx, @three_idx] ]
    end

    # (see RnaSec::Tree::Node#to_vienna)
    #
    def to_vienna
      self.class.to_s + "<#{@five_nuc.upcase}#{@five_idx}-#{@three_nuc.upcase}#{@three_idx}>"
    end

  end

end

