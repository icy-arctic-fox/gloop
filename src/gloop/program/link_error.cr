module Gloop
  struct Program < Object
    # Error raised when the linking process of a program fails.
    #
    # See: `Program#link!`
    class LinkError < Exception
    end
  end
end
