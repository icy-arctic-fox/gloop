require "opengl"

module Gloop
  # Description of how a vertex attribute is stored and the data it contains.
  abstract struct VertexAttributeFormat
    # Number of components in the attribute.
    # This can be 1, 2, 3, or 4.
    getter size : LibGL::Int

    # Creates a vertex attribute format descriptor.
    def initialize(@size)
    end
  end
end
