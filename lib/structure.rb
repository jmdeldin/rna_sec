# Base interface for structural elements of RNA.
module RnaSec
  class Structure
    # nucleotide (symbol)
    def initialize(nuc)
      @nuc = nuc
    end

    # getter -- return the nucleotide symbol as a string
    def nuc
      @nuc.to_s
    end
  end
end

