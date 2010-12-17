# Reads a fasta file and extracts just the sequences
module RnaSec
  class FastaFile
    attr_reader :filename

    def initialize(filename)
      @filename = filename
      @entries  = []
    end

    def entries
      return @entries unless @entries.empty?

      File.open(filename) do |f|
        f.each_line do |l|
          l.gsub!(/\s+/, '')
          next if l[0] == '>' or l.empty?
          l.downcase!
          l.tr!('t', 'u')
          @entries << l
        end
      end

      @entries
    end

    private

    # removes all spaces from the line
    def clean(line)
      line.gsub(/\s+/, '')
    end
  end
end

