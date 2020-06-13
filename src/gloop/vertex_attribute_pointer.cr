require "opengl"

module Gloop
  # Contains information about a vertex attribute's formatting and its position in a buffer.
  abstract struct VertexAttributePointer(Format)
    # Number of bytes to the next attribute of this type.
    getter stride : LibGL::SizeI

    # Byte offset into the vertex buffer where the attribute starts.
    getter offset : Int32

    # Creates the vertex attribute pointer.
    def initialize(@format : Format, @stride, @offset)
    end

    # Number of components in the attribute.
    # This can be 1, 2, 3, or 4.
    def size
      @format.size
    end
  end
end
