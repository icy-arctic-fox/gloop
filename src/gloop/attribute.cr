require "./contextual"
require "./vertex_array/parameters"

module Gloop
  # Information about a vertex attribute from the bound vertex array.
  #
  # This type should be used if direct state access (DSA) isn't available.
  #
  # NOTE: The currently bound vertex array is always referenced.
  # If another vertex array is bound, then this will reference the newly bound instance.
  struct Attribute
    include Contextual
    include Parameters

    # Indicates whether the attribute is enabled for the vertex array.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_ENABLED`
    # - OpenGL version: 2.0
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_ENABLED", version: "2.0")]
    attribute_parameter? VertexAttribArrayEnabled, enabled

    # Index of the attribute.
    getter index : UInt32

    # Creates the attribute reference.
    def initialize(@context : Context, @index : UInt32)
    end

    # Enables the attribute in the vertex array.
    #
    # - OpenGL function: `glEnableVertexAttribArray`
    # - OpenGL version: 2.0
    @[GLFunction("glEnableVertexAttribArray", version: "2.0")]
    def enable
      gl.enable_vertex_attrib_array(@index)
    end

    # Disables the attribute in the vertex array.
    #
    # - OpenGL function: `glDisableVertexAttribArray`
    # - OpenGL version: 2.0
    @[GLFunction("glDisableVertexAttribArray", version: "2.0")]
    def disable
      gl.disable_vertex_attrib_array(@index)
    end
  end
end
