require "opengl"
require "../error_handling"
require "./vertex_buffer_binding_proxy"

module Gloop
  struct VertexArray
    # Provides an intermediate interface to access vertex buffers attached to the vertex array.
    struct VertexBufferBindingCollection
      include ErrorHandling

      # Creates the collection.
      # The *vao* should be the OpenGL ID of the vertex array to proxy access to.
      protected def initialize(@vao : LibGL::UInt)
      end

      # Maximum number of vertex binding slots.
      def size
        checked do
          LibGL.get_integer_v(LibGL::GetPName::MaxVertexAttribBindings, out result)
          result
        end
      end

      # Retrieves the binding slot with the specified index.
      def [](index) : VertexBufferBindingProxy
        VertexBufferBindingProxy.new(@vao, index.to_u32)
      end
    end
  end
end
