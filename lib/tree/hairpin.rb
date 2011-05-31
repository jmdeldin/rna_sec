module RnaSec::Tree

  # Represents a hairpin loop.
  #
  # A hairpin loop occurs when a single-stranded chain folds back on
  # itself.
  #
  class Hairpin < MultiNode

    # (see RnaSec::Tree::MultiNode#get_child_positions)
    #
    def get_child_positions
      [ @five_idx, @three_idx, @children.map { |x| x.idx } ]
    end

  end

end

