require "../error_handling"

module Gloop
  struct VertexArray < Object
    # Reference to a binding slot in a vertex array.
    # Ties vertex buffers and attributes together.
    struct Binding
      include ErrorHandling

      # Name of the vertex array.
      private getter vao : UInt32

      # Index of the binding slot in the vertex array.
      getter index : UInt32

      # Creates a reference to a vertex array's attribute.
      def initialize(@vao : UInt32, @index : UInt32)
      end

      # Associates an attribute with the vertex buffer bound to this slot.
      # The *attribute* should be an index of an attribute in the `VertexArray` this slot belongs to.
      # The *attribute* argument can also be an `AttributeIndex`, but should belong to the same `VertexArray`.
      def attribute=(attribute)
        checked { LibGL.vertex_array_attrib_binding(@vao, attribute, @index) }
      end
    end
  end
end
