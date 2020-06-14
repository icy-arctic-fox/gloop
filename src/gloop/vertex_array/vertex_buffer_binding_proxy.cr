require "opengl"
require "../error_handling"

module Gloop
  struct VertexArray
    # Provides an intermediate interface to modify vertex buffers associated with a vertex array.
    struct VertexBufferBindingProxy
      include ErrorHandling

      # Creates the proxy.
      # The *vao* is the OpenGL ID of the vertex array to proxy access to.
      # The *index* is the binding index to proxy.
      protected def initialize(@vao : LibGL::UInt, @index : LibGL::UInt)
      end

      # Binds a buffer to the slot.
      # The *offset* is the position in the buffer where the first element starts.
      # The *stride* is the distance between elements in the buffer.
      # This is typically the size (in bytes) of each vertex.
      def bind_buffer(buffer, offset, stride)
        checked do
          LibGL.vertex_array_vertex_buffer(@vao, @index, buffer, offset, stride)
        end
      end
    end
  end
end
