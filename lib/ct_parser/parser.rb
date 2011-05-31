module RnaSec::CtParser

  class Parser

    def self.parse(records)
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

