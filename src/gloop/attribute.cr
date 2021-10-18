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

    # Indicates whether the attribute's value is normalized when converted to a float-poing number.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_NORMALIZED`
    # - OpenGL version: 2.0
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_NORMALIZED", version: "2.0")]
    attribute_parameter? VertexAttribArrayNormalized, normalized

    # Indicates whether the attribute's data is an integer on the GPU.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_INTEGER`
    # - OpenGL version: 2.0
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_INTEGER", version: "2.0")]
    attribute_parameter? VertexAttribArrayInteger, integer

    # Indicates whether the attribute's data is a double-precision floating-point value on the GPU.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_LONG`
    # - OpenGL version: 2.0
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_LONG", version: "2.0")]
    attribute_parameter? VertexAttribArrayLong, float64

    # Retrieves the number of components in the attribute.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_SIZE`
    # - OpenGL version: 2.0
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_SIZE", version: "2.0")]
    attribute_parameter VertexAttribArraySize, size

    # Returns the number of bytes between attribute values in the buffer data.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_STRIDE`
    # - OpenGL version: 2.0
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_STRIDE", version: "2.0")]
    attribute_parameter VertexAttribArrayStride, stride

    # Returns the attribute's data type.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_TYPE`
    # - OpenGL version: 2.0
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_TYPE", version: "2.0")]
    attribute_parameter VertexAttribArrayType, type : Float32AttributeFormat::Type

    # Returns the frequency divisor for instanced rendering.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_DIVISOR`
    # - OpenGL version: 4.5
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_DIVISOR", version: "4.5")]
    attribute_parameter VertexAttribArrayDivisor, divisor

    # Retrieves the number of bytes from the start of the vertex buffer data to the first instance of this attribute.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_RELATIVE_OFFSET`
    # - OpenGL version: 4.5
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_RELATIVE_OFFSET", version: "4.5")]
    attribute_parameter VertexAttribRelativeOffset, offset

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
    def float64_format(size : Int32, offset : UInt32, type : Float64AttributeFormat::Type = :float64)
      gl.vertex_attrib_l_format(@index, size, type.to_unsafe, offset)
    end

    # Sets the format of the attribute.
    #
    # The data will be 32-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribFormat", version: "4.3")]
    def format=(format : Float32AttributeFormat)
      float32_format(format.size, format.type, format.normalized?, format.offset)
    end

    # Sets the format of the attribute.
    #
    # The data will be integer values on the GPU.
    #
    # - OpenGL function: `glVertexAttribIFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribIFormat", version: "4.3")]
    def format=(format : IntAttributeFormat)
      int_format(format.size, format.type, format.offset)
    end

    # Sets the format of the attribute.
    #
    # The data will be 64-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribLFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribLFormat", version: "4.3")]
    def format=(format : Float64AttributeFormat)
      float64_format(format.size, format.offset, format.type)
    end
  end
end
