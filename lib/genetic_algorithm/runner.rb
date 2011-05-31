require_relative '../genetic_algorithm'
require_relative '../tree'

class RnaSec::GeneticAlgorithm::Runner

  # @param [RnaSec::Tree::Root] src Fully-populated tree
  # @param [Fixnum] popsize   Desired population size
  # @param [Float]  terminate % of population that must be equal to the source
  # @param [Float]  mutation  % of population to mutate
  #
  def initialize(src, popsize, terminate, mutation)
    @src       = src
    @srcpos    = src.get_child_positions()
    @popsize   = popsize
    @terminate = terminate
    @mutation  = mutation
  end

  # Run the genetic algorithm.
  #
  # == Algorithm
  #
  # 1. Create initial random population
  #
  # 2. Loop:
  #    a. Perform random point mutations on a percentage of the population.
  #       This increases the population size.
  #    b. Get the fitness of the population
  #    c. Greedily select the most fit until the population has been reduced.
  #    d. See how many are equal to the original
  #    e. Terminate if terminating condition has been met
  #
  # @return [void]
  #
  def run
    population = create_initial_pop()

    i = 0
    while true
      # mutate
      to_mut = population.sample(@mutation * @popsize)
      to_mut.each { |t| population << point_mutation(t) }

      # get fitness of the population
      fits   = fitness_pop(population)
      sorted = sort_by_fitness(population, fits)

      # greedily select the top performers
      population = sorted.take(@popsize)

      # re-evaluate fitnesses (for ordering)
      fits = fitness_pop(population)

      # determine how many are identical to @src
      eql_to_orig = 0
      fits.each do |f|
        eql_to_orig += 1 if f == 0
      end

      puts "generation #{i}, #{eql_to_orig}/#{@popsize} are the original"
      if eql_to_orig >= (@terminate * @popsize)
        puts ">=#{@terminate * 100} are equal"
        break
      end

      i += 1
    end
  end

  private

  # Returns a randomized initial population.
  #
  # @return [RnaSec::Tree::Root[]]
  #
  def create_initial_pop
    population = []

    until population.size == @popsize
      population << scramble_tree(@src, @src.size)
    end

    population
  end

  # Randomizes parts of a tree by removing elements and inserting them
  # randomly.
  #
  # @param [RnaSec::Tree::Root] tree  Tree structure
  # @param [Fixnum]             n     Number of nodes to scramble
  #
  # @return [RnaSec::Tree::Root] Randomized tree.
  #
  def scramble_tree(tree, n)
    mutated = tree.clone()
    n.times do
      mutated = point_mutation(mutated)
    end

    mutated
  end

  # Exchanges two nodes in a tree.
  #
  # In this GA, mutation is our source of diversity and our only genetic
  # operator aside from selection.
  #
  # == Algorithm
  #
  # If we want to move a node to another position, we need to prune the
  # node at that position. Thus, for every shuffle, there are two prune
  # and two graft operations.
  #
  # 1. Return the original if the original is an instance of
  #    {RnaSec::Tree::Base} or {RnaSec::Tree::BasePair}. We cannot prune and
  #    graft from these nodes.
  #
  # 2. Select two random nucleotide indexes.
  #
  # 3. Prune whatever nodes are at these positions.
  #
  # 4. Insert the pruned nodes at opposite positions (swap them).
  #
  # 5. Return the shuffled tree.
  #
  # @param [RnaSec::Tree::MultiNode] tree  Tree to shuffle
  #
  # @return [RnaSec::Tree::MultiNode] Shuffled tree
  #
  def point_mutation(tree)
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

      node1 = tree.prune!(r1)
      node2 = tree.prune!(r2)

      # If we pruned a nonexistant element, then we should just return the
      # original tree.
      if node1.nil? || node2.nil?
        return tree
      end

      # swap nodes
      tree.insert(r2, node1)
      tree.insert(r1, node2)
    end

    tree
  end

  # Returns a random nucleotide index from the tree bounds.
  #
  # @param [RnaSec::Tree::MultiNode] tree
  # @return [Fixnum] Random nucleotide index
  #
  def get_rand_nuc_idx(tree)
    min, max = tree.get_bounds()
    rand(1 + max - min) + min
  end

  # Returns the fitness of a single tree compared to the original.
  #
  # This takes the source's nucleotide positions and compares them to
  # the current <tt>tree</tt>. For every mismatch, a -1 is added to the
  # score. A score of 0 indicates the tree is identical to the original.
  #
  # @param [RnaSec::Tree::Root] tree
  # @return [Fixnum]
  #
  def fitness(tree)
    poss = tree.get_child_positions()
    score = 0

    poss.zip(@srcpos) do |pos, src|
      score -= 1 if pos != src
    end

    score
  end

  # Returns the fitness of an entire population.
  #
  # @param [RnaSec::Tree::Root[]] pop Population of Root trees
  # @return [Fixnum[]]
  #
  def fitness_pop(pop)
    fitnesses = []
    pop.each do |p|
      fitnesses << fitness(p)
    end

    fitnesses
  end

  # Returns the population sorted by fitness.
  #
  # @param [RnaSec::Tree::Root[]] pop
  # @param [Fixnum[]] fitnesses
  # @return [RnaSec::Tree::Root[]]
  #
  def sort_by_fitness(pop, fitnesses)
    h = {}
    pop.each_with_index { |p, i| h[p] = fitnesses[i] }
    sorted = h.sort { |a, b| b[1] <=> a[1] } # descending order

    # restore back from [ [:foo, 2], [:bar, 3]] => [:foo, :bar]
    sorted.map { |x| x[0] }
  end

end

