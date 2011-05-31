module RnaSec::Tree

  # Represents a bulge structure.
  #
  # A bulge occurs when unpaired nucleotides disrupt base-pairing on one side.
  #
  class Bulge < MultiNode

    # @param [Array] bases  single stranded bases inside the loop (5' -> 3')
    #
    def initialize(bases = [])
      # foo bar baz
      @five_idx  = bases.first.idx
      @five_nuc  = bases.first.nuc
      @three_idx = bases.last.idx
      @three_nuc = bases.last.nuc
      @children  = bases
    end

    # Returns an array of base indexes.
    #
    # @return [Array]
    #
    def get_child_positions
      @children.map { |x| x.idx }
    end

  end

end

