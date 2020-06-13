require "opengl"

module Gloop
  # Description of how a vertex attribute is stored and the data it contains.
  abstract struct VertexAttributeFormat
    # Number of components in the attribute.
    # This can be 1, 2, 3, or 4.
    getter size : LibGL::Int

    # Number of bytes to the next attribute of this type.
    getter stride : LibGL::SizeI

    # Byte offset into the vertex buffer where the attribute starts.
    getter offset : Int32

    # Creates a vertex attribute format descriptor.
    def initialize(@size, @stride, @offset)
    end
  end
end
