# RNA parser interface
module RnaSec
  class Parser
    def initialize(s)
      raise "#{self.class} must be implemented in a child-class."
    end

    def parse
      raise "#{self.class} must be implemented in a child-class."
    end
  end

  class ParserException < StandardError; end
end

