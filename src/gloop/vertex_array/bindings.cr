require "../contextual"
require "../parameters"
require "./current_binding"

module Gloop
  struct VertexArray < Object
    # Information about all of the binding slots in a vertex array.
    #
    # This type uses direct state access (DSA).
    # Ensure the OpenGL context supports this functionality prior to use.
    struct Bindings
      include Contextual
      include Indexable(Binding)
      include Parameters

      # Retrieves the maximum number of attributes a vertex array can have.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL enum: `GL_MAX_VERTEX_ATTRIB_BINDINGS`
      # - OpenGL version: 4.3
      @[GLFunction("glGetIntegerv", enum: "GL_MAX_VERTEX_ATTRIB_BINDINGS", version: "4.3")]
      parameter MaxVertexAttribBindings, size

      # Creates a references to the binding slots.
      def initialize(@context : Context, @name : Name)
      end

      # Retrieves a binding slot from the vertex array.
      def unsafe_fetch(index : Int)
        Binding.new(@context, @name, index.to_u32!)
      end
    end
  end
end
