module RnaSec::Tree

  # Represents an internal loop.
  #
  # This is a loop that is started by a base pair. It can contain any number of
  # {Base}, {Bulge}, {Hairpin}, and {InternalLoop} structures..
  #
  class InternalLoop < MultiNode
  end

end

