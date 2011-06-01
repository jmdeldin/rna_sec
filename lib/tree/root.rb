module RnaSec::Tree

  # Represents a root node.
  #
  # This class is used as a container for the real secondary structure
  # elements. The problem with secondary structures is there is not a
  # guaranteed, hierarchical root, but this generic object is a decent a
  # solution.
  #
  # @example Initialization
  #   tree = Root.new(array_of_bases)
  #
  class Root < MultiNode

    # @param [Array] children  Array of secondary structures from 5' to 3'
    #
    def initialize(children = [])
      @children = children
    end

    # (see RnaSec::Tree::MultiNode#to_vienna)
    #
    def to_vienna
      s = self.class.to_s

      if children.any?
        s += '(' + children.map { |x| x.to_vienna() }.join(', ') + ')'
      end

      s
    end

  end

end

