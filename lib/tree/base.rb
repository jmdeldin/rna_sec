module RnaSec::Tree

  # Represents a single nucleotide base.
  #
  class Base < Node

    attr_reader :idx
    attr_reader :nuc

    # @param [Fixnum] idx  nucleotide index
    # @param [Symbol] nuc  nucleotide character (e.g., :a, :c, :g, :u})
    #
    def initialize(idx, nuc)
      raise(ArgumentError, 'Index is not an Fixnum') unless idx.is_a? Fixnum
      raise(ArgumentError, 'Nucleotide is not a Symbol') unless nuc.is_a? Symbol
      @idx = idx
      @nuc = nuc
    end

    # Returns the base's index in an array.
    #
    # @note This is provided for compatibility with {MultiNode#get_child_positions}.
    # @todo Update Node with this method
    #
    # @return [Fixnum[]]
    #
    def get_child_positions
      [@idx]
    end

    # (see RnaSec::Tree::Node#to_vienna)
    #
    def to_vienna
      '.'
    end

  end

end

