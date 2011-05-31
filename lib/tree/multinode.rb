module RnaSec::Tree

  # Represents a tree node that contains other nodes.
  #
  # In terms of secondary structure, multinodes are loops or stacks.
  #
  # While this class provides functionality for most of the loop
  # structures, the appropriate, semantic class should be used instead
  # of this generic class. If anything, this class is more of a module
  # than an ancestral class.
  #
  # @note Do not use this directly. Use a more semantic child class instead.
  # @see  Root
  # @see  Hairpin
  # @see  InternalLoop
  #
  class MultiNode < Node

    include Enumerable

    attr_reader :five_idx
    alias :idx :five_idx
    attr_reader :five_nuc

    attr_reader :three_nuc
    attr_reader :three_idx

    attr_accessor :children

    # @param [BasePair] bp        Terminal base pair.
    # @param [Array]    children  Array of subnodes.
    #
    def initialize(bp, children = [])
      unless bp.is_a?(BasePair) && children.is_a?(Array)
        fail(ArgumentError)
      end

      @five_idx  = bp.five_idx
      @five_nuc  = bp.five_nuc
      @three_idx = bp.three_idx
      @three_nuc = bp.three_nuc
      @children  = children
    end

    # (see RnaSec::Tree::Node#to_vienna)
    #
    def to_vienna
      s = self.class.to_s + "<#{@five_nuc.upcase}#{@five_idx}-#{@three_nuc.upcase}#{@three_idx}>"

      if children().any?
        s += '(' + children.map { |x| x.to_vienna() }.join(', ') + ')'
      end

      s
    end

    # Returns the minimum and maximum nucleotide indexes of the children.
    #
    # For the minimum and maximum of just the tree and *not* the
    # children, use {#five_idx} and {#three_idx}.
    #
    # @return [min, max]
    #
    def get_bounds
      min = 999_999_999
      max = -min

      @children.each do |c|
        if c.is_a?(Base)
          # we can't have min == max on Base objs
          if c.idx < min
            min = c.idx
          elsif c.idx > max
            max = c.idx
          end
        else
          min = c.five_idx  if c.five_idx < min
          max = c.three_idx if c.three_idx > max
        end
      end

      [min, max]
    end

    # Returns the number of immediate children.
    #
    # @return [Fixnum]
    #
    def size
      @children.size
    end

    alias :length :size

    # Iterates over the children.
    #
    # @param  [Proc] &blk  Block to call on each child
    # @return [Array]
    #
    def each(&blk)
      @children.each { |c| blk.call(c) }
    end

    # Provides deep-cloning of `@children'.
    #
    # This method is called after an object has been cloned or duplicated, but
    # we need to reset the `@children' array and then copy into it to avoid
    # referencing the same object.
    #
    # @param  [self.class] source
    # @return [self.class]
    #
    def initialize_copy(source)
      super
      @children = []
      source.children.each { |x| @children << x.clone() }
    end

    # Returns an array-of-arrays of the nucleotide indexes.
    #
    # @return [Array]
    #
    def get_child_positions
      arr = self.is_a?(Root) ? [] : [ @five_idx, @three_idx ] 

      if children().any?
        tmp = []
        children().each do |child|
          if child.respond_to?(:get_child_positions)
            tmp += child.get_child_positions()
          else
            fail(RuntimeError, "#{child.class}#get_child_positions is undefined")
          end
        end
        arr << tmp
      end

      arr
    end

    # Returns a structure or nil.
    #
    # @param  [Fixnum] pos  Nucleotide index to locate.
    # @return [Node|MultiNode|nil]
    #
    def find(pos)
      pos = Integer(pos)
      @children.each_with_index do |child, i|
        if child.is_a?(Base)
          return child
        elsif child.five_idx == pos || child.three_idx == pos
          # check the immediate nodes
          return child
        elsif child.five_idx < pos && child.three_idx > pos
          # if 3' > pos and 5' < pos, then it's somewhere down here
          return child.find(pos)
        end
      end

      nil
    end

    # Removes and returns a node from a tree.
    #
    # == Algorithm
    #
    # 1. For each child:
    #
    #    a. If it's a Base, see if it's at the correct position. Remove and
    #       return this node.
    #
    #    b. If it's a MultiNode or BasePair (something with 5' and 3'), see
    #       if either 5' or 3' positions match. Remove and return this node.
    #
    #    c. If it's a MultiNode and the 5' index is < pos and the 3' index
    #       is > position, then our target is contained within this child.
    #       Recursively check this node                                   .
    #
    # 2. Return `nil'.
    #
    # @note This will modify the original tree. Use with caution!
    # @param [Fixnum] pos  Position of the nucleotide to remove
    # @return [MultiNode|Node|nil] The removed structure or nil
    #
    def prune!(pos)
      pos = Integer(pos)
      @children.each_with_index do |child, i|
        if child.is_a?(Base)
          return @children.delete_at(i) if child.idx == pos
        elsif child.five_idx == pos || child.three_idx == pos
          # check the immediate nodes
          return @children.delete_at(i)
        elsif child.five_idx < pos && child.three_idx > pos && !child.is_a?(BasePair)
          # if 3' > pos and 5' < pos, then it's somewhere down here (we also
          # need to explicity exclude basepairs, which don't have children and
          # prune! defined)
          return child.prune!(pos)
        end
      end

      nil
    end

    # Inserts a node onto a tree.
    #
    # == Algorithm
    #
    # 1. If there are no children, insert <tt>tree</tt> as the sole child and
    #    return the tree.
    #
    # 2. Otherwise, for each existing child:
    #
    #    a. If the current child is either one or two positions ahead of
    #       our target <tt>pos</tt>, then insert the <tt>tree</tt> right
    #       before. Return the tree.
    #    b. If we're at the last node and have not inserted, add this
    #       <tt>tree</tt> to the end.
    #
    #  3. Return nil
    #
    # @note This is not recursive, so you must insert into the desired parent.
    # @param [Fixnum] pos  5' index to insert into
    # @param [Node|MultiNode] tree  Node to insert at <tt>pos</tt>
    # @return [nil|self] <tt>self<tt> is returned on success & <tt>nil</tt> on failure
    #
    def insert(pos, tree)
      if @children.empty?
        @children << tree
        return self
      end

      last = @children.length - 1
      @children.each_with_index do |child, i|
        # If the current NUC index is one ahead of the desired position, then we
        # can go ahead and splice the new node into the array
        if child.idx == pos+1 || child.idx == pos+2
          tmp = @children[0 ... i]
          tmp << tree
          tmp += @children[i .. -1]
          @children = tmp
          return self
          # If we're looking at the last element, and we haven't inserted yet,
          # then go ahead and insert
        elsif i == last
          @children << tree
          return self
        end
      end

      # TODO: Couldn't we eliminate the final loop comparison and just insert
      # here if we haven't found a place? I don't think the `nil' return value
      # is being checked by any callers.

      nil
    end

  end

end

