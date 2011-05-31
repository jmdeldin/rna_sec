require_relative 'rnasec'

# This module contains all of the tree structures and operations.
#
module RnaSec::Tree

  # Leaf nodes:
  autoload :Base,         'tree/base'
  autoload :BasePair,     'tree/base_pair'
  autoload :Node,         'tree/node'

  autoload :MultiNode,    'tree/multinode'
  autoload :Root,         'tree/root'
  autoload :Bulge,        'tree/bulge'
  autoload :Hairpin,      'tree/hairpin'
  autoload :InternalLoop, 'tree/internal_loop'

end


