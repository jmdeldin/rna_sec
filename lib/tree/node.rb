# This is an abstract tree node that all tree elements implement.
#
class RnaSec::Tree::Node

  attr_reader :idx

  def initialize
    fail(NotImplementedError, "do not call Node.new directly")
  end

  # Returns a combination of Vienna and expanded Shapiro for debugging.
  #
  #
  # @example Bases
  #   Base.new(3, :g).to_vienna #=> .
  #
  # @example BasePairs
  #   BasePair.new(Base.new(3, :g), Base.new(4, :c)).to_vienna #=> BasePair<G3-C4>
  #
  #
  # @return [String]
  #
  def to_vienna
    fail(NotImplementedError, "#{__method__} not implemented")
  end

end

