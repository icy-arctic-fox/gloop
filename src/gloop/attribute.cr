require "./contextual"
require "./float32_attribute_format"
require "./float64_attribute_format"
require "./int_attribute_format"
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

    # Specifies the format of the attribute.
    #
    # The data will be 32-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribFormat", version: "4.3")]
    def float32_format(size : Int32, type : Float32AttributeFormat::Type, normalized : Bool, offset : UInt32)
      bool = normalized ? LibGL::Boolean::True : LibGL::Boolean::False
      gl.vertex_attrib_format(@index, size, type.to_unsafe, bool, offset)
    end

    # Specifies the format of the attribute.
    #
    # The data will be integer values on the GPU.
    #
    # - OpenGL function: `glVertexAttribIFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribIFormat", version: "4.3")]
    def int_format(size : Int32, type : IntAttributeFormat::Type, offset : UInt32)
      gl.vertex_attrib_i_format(@index, size, type.to_unsafe, offset)
    end

    # Specifies the format of the attribute.
    #
    # The data will be 64-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribLFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribLFormat", version: "4.3")]
    def float64_format(size : Int32, offset : UInt32)
      type = AttributeFormat::Type::Float64
      gl.vertex_attrib_l_format(@name, @index, size, type.to_unsafe, offset)
    end

    # Sets the format of the attribute.
    #
    # The data will be 32-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribFormat`
    # - OpenGL version: 4.5
    @[GLFunction("glVertexAttribFormat", version: "4.5")]
    def format=(format : Float32AttributeFormat)
      self.format(format.size, format.type, format.normalized, format.offset)
    end

    # Sets the format of the attribute.
    #
    # The data will be integer values on the GPU.
    #
    # - OpenGL function: `glVertexAttribIFormat`
    # - OpenGL version: 4.5
    @[GLFunction("glVertexAttribIFormat", version: "4.5")]
    def format=(format : IntAttributeFormat)
      self.format(format.size, format.type, format.offset)
    end

    # Sets the format of the attribute.
    #
    # The data will be 64-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribLFormat`
    # - OpenGL version: 4.5
    @[GLFunction("glVertexAttribLFormat", version: "4.5")]
    def format=(format : Float64AttributeFormat)
      self.format(format.size, format.offset)
    end
  end
end
