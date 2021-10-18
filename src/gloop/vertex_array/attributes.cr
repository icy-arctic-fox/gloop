require "../contextual"
require "../parameters"
require "./attribute"

module Gloop
  struct VertexArray < Object
    # Information about all of the attributes in a vertex array.
    #
    # This type uses direct state access (DSA).
    # Ensure the OpenGL context supports this functionality prior to use.
    struct Attributes
      include Contextual
      include Indexable(Attribute)
      include Parameters

      # Retrieves the maximum number of attributes a vertex array can have.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL enum: `GL_MAX_VERTEX_ATTRIBS`
      # - OpenGL version: 3.0
      @[GLFunction("glGetIntegerv", enum: "GL_MAX_VERTEX_ATTRIBS", version: "3.0")]
      parameter MaxVertexAttribs, size

      # Creates a references to the attributes for a vertex array.
      def initialize(@context : Context, @name : Name)
      end

      # Retrieves an attribute from the vertex array.
      def unsafe_fetch(index : Int)
        Attribute.new(@context, @name, index.to_u32!)
      end
    end
  end
end
