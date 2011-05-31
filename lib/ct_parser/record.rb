module RnaSec::CtParser

  # Represents a row from (una|m)fold's connected-table (CT) format.
  #
  # A CT file contains six columns separated by tabs:
  #
  # 1. i (index)
  # 2. r_i (nucleotide character)
  # 3. Index of the 5' connecting base. 0 if there is no 5' predecessor.
  # 4. Index of the 3' connecting base. 0 if there is no 3' successor.
  # 5. Index of the paired base. 0 if it's not paired.
  # 6. i (same as #1)
  #
  class Record

    attr_reader :idx
    attr_reader :nuc
    attr_reader :five_idx
    attr_reader :three_idx
    attr_reader :pair_idx

    # Input the first five columns of a CT file.
    #
    # @param [Fixnum] i
    # @param [Symbol] nuc
    # @param [Fixnum] five_idx
    # @param [Fixnum] three_idx
    # @param [Fixnum] pair_idx
    #
    def initialize(i, nuc, five_idx, three_idx, pair_idx)
      @idx       = i
      @nuc       = nuc
      @five_idx  = five_idx
      @three_idx = three_idx
      @pair_idx  = pair_idx
    end

    # Returns a record from an array.
    #
    # @param  [Array] arr Array of strings
    # @return [Record]
    #
    def self.from_array(arr)
      Record.new(
        arr[0].to_i,
        arr[1].downcase.to_sym,
        arr[2].to_i,
        arr[3].to_i,
        arr[4].to_i
      )
    end

  end

end

