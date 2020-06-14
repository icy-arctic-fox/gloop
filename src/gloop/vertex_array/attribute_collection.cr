require "opengl"
require "../error_handling"
require "./attribute_proxy"

module Gloop
  struct VertexArray
    # Provides an intermediate interface to access attributes attached to the vertex array.
    struct AttributeCollection
      include ErrorHandling

      # Creates the collection.
      # The *vao* should be the OpenGL ID of the vertex array to proxy access to.
      protected def initialize(@vao : LibGL::UInt)
      end

      # Maximum number of allowed vertex attributes.
      def size
        checked do
          LibGL.get_integer_v(LibGL::GetPName::MaxVertexAttribs, out result)
          result
        end
      end

      # Retrieves the attribute with the specified index.
      def [](index) : AttributeProxy
        AttributeProxy.new(@vao, index.to_u32)
      end
    end
  end
end
