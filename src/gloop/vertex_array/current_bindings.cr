require "../contextual"
require "../parameters"
require "./current_binding"

module Gloop
  struct VertexArray < Object
    # Information about all of the binding slots in a vertex array.
    #
    # This type should be used if direct state access (DSA) isn't available.
    #
    # NOTE: The currently bound vertex array is always referenced.
    # If another vertex array is bound, then this will reference the newly bound instance.
    struct CurrentBindings
      include Contextual
      include Indexable(CurrentBinding)
      include Parameters

      def_context_initializer

      # Retrieves the maximum number of attributes a vertex array can have.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL enum: `GL_MAX_VERTEX_ATTRIB_BINDINGS`
      # - OpenGL version: 4.3
      @[GLFunction("glGetIntegerv", enum: "GL_MAX_VERTEX_ATTRIB_BINDINGS", version: "4.3")]
      parameter MaxVertexAttribBindings, size

      # Retrieves a binding slot from the vertex array.
      def unsafe_fetch(index : Int)
        CurrentBinding.new(@context, index.to_u32!)
      end
    end
  end

  struct Context
    # Information about vertex buffer and attribute binding slots.
    def bindings : VertexArray::CurrentBindings
      VertexArray::CurrentBindings.new(self)
    end
  end
end
