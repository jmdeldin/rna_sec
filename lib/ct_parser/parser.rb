module RnaSec::CtParser

  # Extracts secondary structure from a CT file.
  #
  # @see Record
  # @see Rules
  #
  class Parser

    # Parses a set of record objects into a tree structure.
    #
    # @param [Record[]] records
    # @return [RnaSec::Tree::Root]
    #
    def self.parse(records)
      root       = RnaSec::Tree::Root.new

      last       = nil  # last structure, not inserted yet
      bases      = []   # bases that haven't been allocated to a structure
      three_down = []   # list of 3' indices
      curroot    = root # the node that `acquires' children in each iteration

      records.each_with_index do |rec, i|
        rule = Rules.new(rec, last, bases)

        cur  = nil # what we think it is

        # If we saw a hairpin, add the hairpin to the curroot, clear out bases
        if rule.hairpin?
          cur = RnaSec::Tree::Hairpin.new(last, bases)
          curroot << cur
          bases = []

        elsif rule.base_pair_part?

          # If we are looking at the 5' end, make the BasePair before we
          # actually see the 3' end.
          if rec.idx < rec.pair_idx
            cur = RnaSec::Tree::BasePair.new(
              RnaSec::Tree::Base.new(rec.idx, rec.nuc),
              RnaSec::Tree::Base.new(rec.pair_idx, records[rec.pair_idx-1].nuc)
            )
            three_down << rec.pair_idx
          else
            # Since we already made the BP when we saw the 5' end, skip this
            # record. We check for bases just in case this is a BP part
            # following a bulge.
            unless bases.any?
              three_down.pop()
              next
            end
          end

          # We just saw an IL, so add current root as a child of the
          # existing root and make a new current root
          if rule.internal_loop?
            newroot = RnaSec::Tree::InternalLoop.new(last)
            curroot << newroot
            curroot = newroot
          elsif rule.bulge?
            curroot << RnaSec::Tree::Bulge.new(bases)
            bases = []
          end

        elsif rule.single?
          cur = RnaSec::Tree::Base.new(rec.idx, rec.nuc)
          bases << cur
          next
        end

        last = cur
      end

      # Sometimes, we have a trailing strand of bases
      if bases.any?
        curroot << RnaSec::Tree::Bulge.new(bases)
        bases = []
      end

       root
    end

    # Converts each line of the CT file into Record objects.
    #
    # @param [String] fn   CT filename
    # @return [Record[]]   Array of Records
    #
    def self.get_records(fn)
      arr = File.open(fn, 'r').readlines

      # remove the informational first line
      arr.shift

      # remove newines and split by tab
      arr.map! do |a|
        a.chomp
        a.split(/\t/)
      end

      # put into record objects
      records = []
      arr.each do |a|
        records << Record.from_array(a)
      end

      records
    end

  end

end

