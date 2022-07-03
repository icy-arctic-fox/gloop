require "../attributes"
require "../contextual"
require "../parameters"

module Gloop
  struct VertexArray < Object
    # References the currently bound vertex array for a context.
    #
    # This type should be used if direct state access (DSA) isn't available.
    #
    # NOTE: The currently bound vertex array is always referenced.
    # If another vertex array is bound, then this will reference the newly bound instance.
    struct Current
      include Contextual
      include Parameters

      def_context_initializer

      # Retrieves the name of the currently bound vertex array.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL enum: `GL_VERTEX_ARRAY_BINDING`
      # - OpenGL version: 3.0
      @[GLFunction("glGetIntegerv", enum: "GL_VERTEX_ARRAY_BINDING", version: "3.0")]
      protected parameter VertexArrayBinding, name : Name

      # Checks if there is a vertex array currently bound.
      def bound?
        !name.zero?
      end

      # Unbinds any previously bound vertex array from the context.
      #
      # - OpenGL function: `glBindVertexArray`
      # - OpenGL version: 3.0
      @[GLFunction("glBindVertexArray", version: "3.0")]
      def unbind : Nil
        none = Name.new!(0)
        gl.bind_vertex_array(none)
      end

      # Information for all attributes in the bound vertex array.
      def attributes : Gloop::Attributes
        Gloop::Attributes.new(@context)
      end

      # Ties a vertex buffer to a binding slot (index) to be associated with an attribute.
      #
      # See: `#bind_attribute`
      #
      # - OpenGL function: `glBindVertexBuffer`
      # - OpenGL version: 4.3
      @[GLFunction("glBindVertexBuffer", version: "4.3")]
      def bind_vertex_buffer(buffer : Buffer, to slot : UInt32, offset : Size, stride : Int32)
        gl.bind_vertex_buffer(slot, buffer.to_unsafe, offset, stride)
      end

      # TODO: bind_vertex_buffers

      # Ties an attribute to a binding slot (index) to be associated with a vertex buffer.
      #
      # See: `#bind_vertex_buffer`
      #
      # - OpenGL function: `glVertexAttribBinding`
      # - OpenGL version: 4.3
      @[GLFunction("glVertexAttribBinding", version: "4.5")]
      def bind_attribute(attribute : Gloop::Attribute, to slot : UInt32)
        gl.vertex_attrib_binding(attribute.index, slot)
      end

      # Information about vertex buffer and attribute binding slots.
      def bindings : CurrentBindings
        CurrentBindings.new(@context)
      end
    end
  end

  struct Context
    # Always references the currently bound vertex array.
    #
    # See: `VertexArray::Current`
    def bound_vertex_array : VertexArray::Current
      VertexArray::Current.new(self)
    end
  end
end
