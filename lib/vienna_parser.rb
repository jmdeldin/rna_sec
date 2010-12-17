require_relative 'parser'
require_relative 'base'
require_relative 'hairpin'
require_relative 'tree'

# Vienna Notation Parser
module RnaSec
  class ViennaParser

    # seq    -- sequence
    # vienna -- Vienna notation
    def initialize(seq, vienna)
      @seq   = seq.downcase
      @vienna = vienna
    end

    # returns a tree
    def parse
      raise ParserException, "Uneven lengths" if @seq.length != @vienna.length

      #
      # determine the root node
      #

      # hairpin
      if @vienna[0] == '(' && @vienna[-1] == ')'
        tree = Tree.new(
          :key1 => Hairpin.new(get_nuc(0), :start),
          :key2 => Hairpin.new(get_nuc(-1), :end),
        )
      # base pairs at 5' and 3'
      elsif @vienna[0] == '.' && @vienna[-1] == '.'
        tree = Tree.new(
          :key1 => Base.new(get_nuc(0)),
          :key2 => Base.new(get_nuc(-1)),
        )
      elsif @vienna[0] == '.' && @vienna[-1] == ')'
        tree = Tree.new(
          :key1 => Base.new(get_nuc(0))
        )
      else
        raise "Unable to build tree structure"
      end

      # figure out what the rest of the sequence is
      i = 1
      @vienna[1..-2].each_char do |c|
        if c == '.'
          tree.children << Node.new(:key1 => Base.new(get_nuc(i)))
        elsif c == '('
          tree.children << Node.new(:key1 => Hairpin.new(get_nuc(i), :start))
        elsif c == ')'
          tree.children << Node.new(:key1 => Hairpin.new(get_nuc(i), :end))
        end
        i += 1
      end

      tree
    end

    private

    def get_nuc(i)
      @seq[i].to_sym
    end

  end
end

