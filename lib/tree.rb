#
# Classes for representing secondary structure as trees.
#
# The recursive tree definition is:
#
#   Tree =
#     | Nil                          /-child nodes
#     | Node Structure * Structure * Node[]
#     |      \-root       \-opt. root
#
#

module RnaSec
  class Node
    attr_accessor :root, :children
    attr_reader   :key1, :key2

    # options -- {:key1, :key2, :children}
    def initialize(options)
      @key1     = options[:key1]
      @key2     = options[:key2]
      @children = options[:children] || []
    end

    # return Vienna representation
    def to_vienna
      s = @key1.to_s
      @children.each { |x| s << x.to_vienna }
      s << @key2.to_s
    end

    # return RNA sequence
    def to_sequence
      s = @key1.nuc
      @children.each { |x| s << x.to_sequence } if @children
      s << @key2.nuc if @key2
      s.to_s # TODO: why does the .each above fail w/o .to_s despite this being a str?
    end
  end

  # Semantic distinction between nodes and the overall root node.
  class Tree < Node
  end
end

