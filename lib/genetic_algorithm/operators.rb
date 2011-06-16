# Genetic operators on trees.
#
module RnaSec::GeneticAlgorithm::Operators

  # Splices a new set of bases into a bulge or hairpin.
  #
  # The target bulge will be split into two bulges/hairpins.
  #
  # @param [RnaSec::Tree::Hairpin|RnaSec::Tree::Bulge] insert Node to insert
  # @param [RnaSec::Tree::Hairpin|RnaSec::Tree::Bulge] into Struct to insert into
  # @param [Fixnum] pos Array position in <tt>into</tt> to insert at
  # @return [RnaSec::Tree::InternalLoop|*] Parent of <tt>into</tt>
  #
  def self.splice!(insert, into, pos)

    parent = into.parent()
    parent.prune!(into.five_idx)

    sz = into.children.size()
    if sz > 1
      bases1 = into.children[0 ... pos]
      bases2 = into.children[pos .. -1]
      case pos
      when 0
        parent << insert
        parent << into
      when into.children.size - 1
        parent << into
        parent << insert
      else
        if into.is_a? RnaSec::Tree::Hairpin
          parent << RnaSec::Tree::Hairpin.new(into.bp, bases1)
        else
          parent << into.class.new(bases1)
        end

        parent << insert

        if into.is_a? RnaSec::Tree::Hairpin
          parent << RnaSec::Tree::Hairpin.new(into.bp, bases2)
        else
          parent << into.class.new(bases2)
        end
      end
    else
      parent << insert
      parent << into
    end
  end

  # Point mutation for a tree.
  #
  # In this GA, mutation is our source of diversity and our only genetic
  # operator aside from selection.
  #
  # == Algorithm
  #
  # If we want to move a node to another position, we need to prune the
  # node at that position. Thus, for every shuffle, there are at least two
  # prune and two graft operations.
  #
  # 1. Return the original if the original is an instance of
  #    {RnaSec::Tree::Base} or {RnaSec::Tree::BasePair}. We cannot prune and
  #    graft from these nodes.
  #
  # 2. Select two random nucleotide indexes.
  #
  # 3. If one nucleotide is a Base|Bulge|Hairpin and the other is a
  #    Bulge|Hairpin, call #splice!
  #
  #    Else:
  #      a. Prune whatever nodes are at these positions.
  #
  #      b. Insert the pruned nodes at opposite positions (swap them).
  #
  # 4. Return the shuffled tree.
  #
  # @param [RnaSec::Tree::MultiNode] tree  Tree to shuffle
  #
  # @return [RnaSec::Tree::MultiNode] Shuffled tree
  #
  def self.point_mutation(tree)
    tree = tree.clone()

    # We can't do anything with Base and BasePair objects.
    unless tree.is_a?(RnaSec::Tree::Base) || tree.is_a?(RnaSec::Tree::BasePair)
      # nodes to swap
      r1 = get_rand_nuc_idx(tree)
      r2 = get_rand_nuc_idx(tree)

      # We might pick the same element twice, but we're doing sampling with
      # replacement, so we can just return the tree.
      if r1 == r2
        return tree
      end

      main_case = [RnaSec::Tree::Bulge, RnaSec::Tree::Hairpin]

      node1 = tree.prune!(r1)
      node2 = tree.prune!(r2)

      # If we pruned a nonexistent element, then we should just return the
      # original tree.
      if node1.nil? || node2.nil? || node1.is_a?(RnaSec::Tree::BasePair) || node2.is_a?(RnaSec::Tree::BasePair)
        return tree
      end

      if main_case.include?(node1.class) && main_case.include?(node2.class)
        # This means we need to break apart r2 and insert r1
        # puts "class= #{node1.class}...#{node2.class}"
        pos = rand(node2.children.size + 1)
        tree = self.splice!(node1, node2, pos)
      else
        # swap nodes
        tree.insert(r2, node1)
        tree.insert(r1, node2)
      end
    end

    tree
  end

  # Returns a random nucleotide index from the tree bounds.
  #
  # @param [RnaSec::Tree::MultiNode] tree
  # @return [Fixnum] Random nucleotide index
  #
  def self.get_rand_nuc_idx(tree)
    min, max = tree.get_bounds()
    rand(1 + max - min) + min
  end
end

