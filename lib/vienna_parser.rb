require_relative 'parser'
require_relative 'base'
require_relative 'hairpin'

# Vienna Notation Parser
module RnaSec
  class ViennaParser

    # seqs   -- sequence
    # vienna -- Vienna notation
    def initialize(seqs, vienna)
      @seqs   = seqs.downcase
      @vienna = vienna
    end

    # returns a tree
    def parse
      # FIXME: Do this as a tree
      parsed = []

      raise "Uneven lengths" if @seqs.length != @vienna.length

      i = 0
      @vienna.each_char do |c|
        if c == '.'
          parsed << Base.new(@seqs[i].to_sym)
        elsif c == '('
          parsed << Hairpin.new(@seqs[i].to_sym, :start)
        elsif c == ')'
          parsed << Hairpin.new(@seqs[i].to_sym, :end)
        end
        i += 1
      end

      parsed
    end
  end
end

