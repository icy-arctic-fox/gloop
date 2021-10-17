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

      # Retrieves the name of the currently bound vertex array.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL enum: `GL_VERTEX_ARRAY_BINDING`
      # - OpenGL version: 3.0
      @[GLFunction("glGetIntegerv", enum: "GL_VERTEX_ARRAY_BINDING", version: "3.0")]
      protected parameter VertexArrayBinding, name : Name

      # Creates a reference to the currently bound vertex array.
      def initialize(@context : Context)
      end

      # Checks if there is a vertex array currently bound.
      def bound?
        !name.zero?
      end

      # Unbinds any previously bound vertex array from the context.
      #
      # - OpenGL function: `glBindVertexArray`
      # - OpenGL version: 3.0
      @[GLFunction("glBindVertexArray", version: "3.0")]
      def unbind
        none = Name.new!(0)
        gl.bind_vertex_array(none)
      end
    end
  end
end
