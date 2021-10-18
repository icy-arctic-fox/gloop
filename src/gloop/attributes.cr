require "./attribute"
require "./contextual"
require "./parameters"

module Gloop
  # Information about all of the attributes in the currently bound vertex array.
  #
  # This type should be used if direct state access (DSA) isn't available.
  #
  # NOTE: The currently bound vertex array is always referenced.
  # If another vertex array is bound, then this will reference the newly bound instance.
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

    # Creates a references to the attributes for the bound vertex array.
    def initialize(@context : Context)
    end

    # Retrieves an attribute from the vertex array.
    def unsafe_fetch(index : Int)
      Attribute.new(@context, index.to_u32!)
    end
  end
end
