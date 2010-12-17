# wrapper around RNAFold

module RnaSec
  class RnaFold
    attr_reader :seq

    # seq -- sequence to fold
    def initialize(seq)
      @seq     = seq
      @results = ''
    end

    # runs RNAFold on @seq
    def results
      return @results unless @results.empty?

      results = `echo #{@seq} | RNAFold -noPS`.split("\n")

      # find the structure
      vienna = nil
      results.each do |l|
        if l[0] == '.' || l[0] == '('
          # the structure is terminated with a space, so remove that space
          vienna = l.sub(/\s+.*/, '')
        end
      end

      raise 'RNAFold could not find a structure' if vienna.nil?

      vienna
    end
  end
end

