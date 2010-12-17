require_relative 'structure'

# Represents either a start or ending structure of RNA, e.g., opening of a
# hairpin loop.
module RnaSec
  class EndedStructure < Structure
    attr_reader :type

    # nuc  -- nucleotide (symbol)
    # type -- start/end of loop (symbol -- :start, :end)
    def initialize(nuc, type)
      super(nuc)
      @type = type
    end

    def to_s
      @type == :start ? '(' : ')'
    end
  end
end

