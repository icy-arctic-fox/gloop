require "./attribute_format"
require "./attribute_pointer"
require "./contextual"
require "./float32_attribute_format"
require "./float32_attribute_pointer"
require "./float64_attribute_format"
require "./float64_attribute_pointer"
require "./int_attribute_format"
require "./int_attribute_pointer"
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
    # - OpenGL version: 3.2
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_DIVISOR", version: "3.2")]
    attribute_parameter VertexAttribArrayDivisor, divisor : UInt32

    # Retrieves the number of bytes from the start of the vertex buffer data to the first instance of this attribute.
    #
    # - OpenGL function: `glGetVertexAttribiv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_RELATIVE_OFFSET`
    # - OpenGL version: 4.3
    @[GLFunction("glGetVertexAttribiv", enum: "GL_VERTEX_ATTRIB_ARRAY_RELATIVE_OFFSET", version: "4.3")]
    attribute_parameter VertexAttribRelativeOffset, relative_offset : UInt32

    # Context associated with the attribute reference.
    private getter context : Context

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
    def enable : Nil
      gl.enable_vertex_attrib_array(@index)
    end

    # Disables the attribute in the vertex array.
    #
    # - OpenGL function: `glDisableVertexAttribArray`
    # - OpenGL version: 2.0
    @[GLFunction("glDisableVertexAttribArray", version: "2.0")]
    def disable : Nil
      gl.disable_vertex_attrib_array(@index)
    end

    # Retrieves the offset within buffer data to the first value of the attribute.
    #
    # - OpenGL function: `glGetVertexAttribPointerv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_POINTER`
    # - OpenGL version: 2.0
    @[GLFunction("glGetVertexAttribPointerv", enum: "GL_VERTEX_ATTRIB_ARRAY_POINTER", version: "2.0")]
    def address : Size
      Size.new(data_pointer.address)
    end

    # Retrieves the pointer within buffer data to the first value of the attribute.
    #
    # - OpenGL function: `glGetVertexAttribPointerv`
    # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_POINTER`
    # - OpenGL version: 2.0
    @[GLFunction("glGetVertexAttribPointerv", enum: "GL_VERTEX_ATTRIB_ARRAY_POINTER", version: "2.0")]
    def data_pointer : Void*
      pname = LibGL::VertexAttribPointerPropertyARB::VertexAttribArrayPointer
      pointer = uninitialized Void*
      gl.get_vertex_attrib_pointer_v(@index, pname, pointerof(pointer))
      pointer
    end

    # Specifies the format of the attribute.
    #
    # The data will be 32-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribFormat", version: "4.3")]
    def specify_format(size : Int32, type : Float32AttributeFormat::Type, normalized : Bool, relative_offset : UInt32) : Nil
      gl.vertex_attrib_format(@index, size, type.to_unsafe, gl_bool(normalized), relative_offset)
    end

    # Specifies the format of the attribute.
    #
    # The data will be integer values on the GPU.
    #
    # - OpenGL function: `glVertexAttribIFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribIFormat", version: "4.3")]
    def specify_int_format(size : Int32, type : IntAttributeFormat::Type, relative_offset : UInt32) : Nil
      gl.vertex_attrib_i_format(@index, size, type.to_unsafe, relative_offset)
    end

    # Specifies the format of the attribute.
    #
    # The data will be 64-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribLFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribLFormat", version: "4.3")]
    def specify_float64_format(size : Int32, relative_offset : UInt32, type : Float64AttributeFormat::Type = :float64) : Nil
      gl.vertex_attrib_l_format(@index, size, type.to_unsafe, relative_offset)
    end

    # Retrieves all format information about the attribute.
    def format : AttributeFormat
      case
      when integer? then IntAttributeFormat.new(size, type.unsafe_as(IntAttributeFormat::Type), relative_offset)
      when float64? then Float64AttributeFormat.new(size, relative_offset)
      else               Float32AttributeFormat.new(size, type, normalized?, relative_offset)
      end
    end

    # Specifies a pointer to attribute data.
    #
    # The data will be 32-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribPointer`
    # - OpenGL version: 2.0
    @[GLFunction("glVertexAttribPointer", version: "2.0")]
    def specify_pointer(size : Int32, type : Float32AttributePointer::Type, normalized : Bool,
                        stride : Int32 = 0, address : Size = 0) : Nil
      gl.vertex_attrib_pointer(@index, size, type.to_unsafe, gl_bool(normalized), stride, gl_pointer(address))
    end

    # Specifies a pointer to attribute data.
    #
    # The data will be integer values on the GPU.
    #
    # - OpenGL function: `glVertexAttribIPointer`
    # - OpenGL version: 3.0
    @[GLFunction("glVertexAttribIPointer", version: "3.0")]
    def specify_int_pointer(size : Int32, type : IntAttributePointer::Type, stride : Int32 = 0, address : Size = 0) : Nil
      gl.vertex_attrib_i_pointer(@index, size, type.to_unsafe, stride, gl_pointer(address))
    end

    # Specifies a pointer to attribute data.
    #
    # The data will be 64-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribLPointer`
    # - OpenGL version: 4.1
    @[GLFunction("glVertexAttribLPointer", version: "4.1")]
    def specify_float64_pointer(size : Int32, stride : Int32 = 0, address : Size = 0,
                                type : Float64AttributePointer::Type = :float64) : Nil
      gl.vertex_attrib_l_pointer(@index, size, type.to_unsafe, stride, gl_pointer(address))
    end

    # Retrieves all format information about the attribute.
    def pointer : AttributePointer
      case
      when integer? then IntAttributePointer.new(size, type.unsafe_as(IntAttributePointer::Type), stride, address)
      when float64? then Float64AttributePointer.new(size, stride, address)
      else               Float32AttributePointer.new(size, type.unsafe_as(Float32AttributePointer::Type), normalized?, stride, address)
      end
    end

    # Sets the format of the attribute.
    #
    # The data will be 32-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribFormat", version: "4.3")]
    def format=(format : Float32AttributeFormat)
      specify_format(format.size, format.type, format.normalized?, format.relative_offset)
    end

    # Sets the format of the attribute.
    #
    # The data will be integer values on the GPU.
    #
    # - OpenGL function: `glVertexAttribIFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribIFormat", version: "4.3")]
    def format=(format : IntAttributeFormat)
      specify_int_format(format.size, format.type, format.relative_offset)
    end

    # Sets the format of the attribute.
    #
    # The data will be 64-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribLFormat`
    # - OpenGL version: 4.3
    @[GLFunction("glVertexAttribLFormat", version: "4.3")]
    def format=(format : Float64AttributeFormat)
      specify_float64_format(format.size, format.relative_offset, format.type)
    end

    # Specifies a pointer to attribute data.
    #
    # The data will be 32-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribPointer`
    # - OpenGL version: 2.0
    @[GLFunction("glVertexAttribPointer", version: "2.0")]
    def pointer=(pointer : Float32AttributePointer)
      specify_pointer(pointer.size, pointer.type, pointer.normalized?, pointer.stride, pointer.address)
    end

    # Specifies a pointer to attribute data.
    #
    # The data will be integer values on the GPU.
    #
    # - OpenGL function: `glVertexAttribIPointer`
    # - OpenGL version: 3.0
    @[GLFunction("glVertexAttribIPointer", version: "3.0")]
    def pointer=(pointer : IntAttributePointer)
      specify_int_pointer(pointer.size, pointer.type, pointer.stride, pointer.address)
    end

    # Specifies a pointer to attribute data.
    #
    # The data will be 64-bit floating-point values on the GPU.
    #
    # - OpenGL function: `glVertexAttribLPointer`
    # - OpenGL version: 4.1
    @[GLFunction("glVertexAttribLPointer", version: "4.1")]
    def pointer=(pointer : Float64AttributePointer)
      specify_float64_pointer(pointer.size, pointer.stride, pointer.address, pointer.type)
    end

    # Sets the rate at which attribute values advance during instances rendering.
    #
    # - OpenGL function: `glVertexAttribDivisor`
    # - OpenGL version: 3.2
    @[GLFunction("glVertexAttribDivisor", version: "3.2")]
    def divisor=(divisor : UInt32)
      gl.vertex_attrib_divisor(@index, divisor)
    end

    # Converts a Crystal boolean to an OpenGL boolean enum.
    private def gl_bool(flag)
      flag ? LibGL::Boolean::True : LibGL::Boolean::False
    end

    # Converts an integer address to a pointer (of sorts).
    private def gl_pointer(address)
      Pointer(Void).new(address)
    end
  end
end
