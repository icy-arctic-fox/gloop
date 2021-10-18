require "../contextual"
require "./parameters"

module Gloop
  struct VertexArray < Object
    # Information about a vertex attribute from a vertex array.
    #
    # This type uses direct state access (DSA).
    # Ensure the OpenGL context supports this functionality prior to use.
    struct Attribute
      include Contextual
      include Parameters

      # Indicates whether the attribute is enabled for the vertex array.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_ENABLED`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_ATTRIB_ARRAY_ENABLED", version: "4.5")]
      array_attribute_parameter? VertexAttribArrayEnabled, enabled

      # Name of the vertex array.
      private getter name : Name

      # Index of the attribute.
      getter index : UInt32

      # Creates the attribute reference.
      def initialize(@context : Context, @name : Name, @index : UInt32)
      end

      # Enables the attribute in the vertex array.
      #
      # - OpenGL function: `glEnableVertexArrayAttrib`
      # - OpenGL version: 4.5
      @[GLFunction("glEnableVertexArrayAttrib", version: "4.5")]
      def enable
        gl.enable_vertex_array_attrib(@name, @index)
      end

      # Disables the attribute in the vertex array.
      #
      # - OpenGL function: `glDisableVertexArrayAttrib`
      # - OpenGL version: 4.5
      @[GLFunction("glDisableVertexArrayAttrib", version: "4.5")]
      def disable
        gl.disable_vertex_array_attrib(@name, @index)
      end
    end
  end
end
