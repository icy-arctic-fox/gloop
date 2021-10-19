require "../attribute_format"
require "../contextual"
require "../float32_attribute_format"
require "../float64_attribute_format"
require "../int_attribute_format"
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

      # Indicates whether the attribute's value is normalized when converted to a float-poing number.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_NORMALIZED`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_ATTRIB_ARRAY_NORMALIZED", version: "4.5")]
      array_attribute_parameter? VertexAttribArrayNormalized, normalized

      # Indicates whether the attribute's data is an integer on the GPU.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_INTEGER`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_ATTRIB_ARRAY_INTEGER", version: "4.5")]
      array_attribute_parameter? VertexAttribArrayInteger, integer

      # Indicates whether the attribute's data is a double-precision floating-point value on the GPU.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_LONG`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_ATTRIB_ARRAY_LONG", version: "4.5")]
      array_attribute_parameter? VertexAttribArrayLong, float64

      # Retrieves the number of components in the attribute.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_SIZE`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_ATTRIB_ARRAY_SIZE", version: "4.5")]
      array_attribute_parameter VertexAttribArraySize, size

      # Returns the number of bytes between attribute values in the buffer data.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_STRIDE`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_ATTRIB_ARRAY_STRIDE", version: "4.5")]
      array_attribute_parameter VertexAttribArrayStride, stride

      # Returns the attribute's data type.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_TYPE`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_ATTRIB_ARRAY_TYPE", version: "4.5")]
      array_attribute_parameter VertexAttribArrayType, type : Float32AttributeFormat::Type

      # Returns the frequency divisor for instanced rendering.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_DIVISOR`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_ATTRIB_ARRAY_DIVISOR", version: "4.5")]
      array_attribute_parameter VertexAttribArrayDivisor, divisor : UInt32

      # Retrieves the number of bytes from the start of the vertex buffer data to the first instance of this attribute.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_ATTRIB_ARRAY_RELATIVE_OFFSET`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_ATTRIB_ARRAY_RELATIVE_OFFSET", version: "4.5")]
      array_attribute_parameter VertexAttribRelativeOffset, relative_offset : UInt32

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
      def enable : Nil
        gl.enable_vertex_array_attrib(@name, @index)
      end

      # Disables the attribute in the vertex array.
      #
      # - OpenGL function: `glDisableVertexArrayAttrib`
      # - OpenGL version: 4.5
      @[GLFunction("glDisableVertexArrayAttrib", version: "4.5")]
      def disable : Nil
        gl.disable_vertex_array_attrib(@name, @index)
      end

      # Specifies the format of the attribute.
      #
      # The data will be 32-bit floating-point values on the GPU.
      #
      # - OpenGL function: `glVertexArrayAttribFormat`
      # - OpenGL version: 4.5
      @[GLFunction("glVertexArrayAttribFormat", version: "4.5")]
      def float32_format(size : Int32, type : Float32AttributeFormat::Type, normalized : Bool, relative_offset : UInt32) : Nil
        bool = normalized ? LibGL::Boolean::True : LibGL::Boolean::False
        gl.vertex_array_attrib_format(@name, @index, size, type.to_unsafe, bool, relative_offset)
      end

      # Specifies the format of the attribute.
      #
      # The data will be integer values on the GPU.
      #
      # - OpenGL function: `glVertexArrayAttribIFormat`
      # - OpenGL version: 4.5
      @[GLFunction("glVertexArrayAttribIFormat", version: "4.5")]
      def int_format(size : Int32, type : IntAttributeFormat::Type, relative_offset : UInt32) : Nil
        gl.vertex_array_attrib_i_format(@name, @index, size, type.to_unsafe, relative_offset)
      end

      # Specifies the format of the attribute.
      #
      # The data will be 64-bit floating-point values on the GPU.
      #
      # - OpenGL function: `glVertexArrayAttribLFormat`
      # - OpenGL version: 4.5
      @[GLFunction("glVertexArrayAttribLFormat", version: "4.5")]
      def float64_format(size : Int32, relative_offset : UInt32, type : Float64AttributeFormat::Type = :float64) : Nil
        gl.vertex_array_attrib_l_format(@name, @index, size, type.to_unsafe, relative_offset)
      end

      # Retrieves all format information about the attribute.
      def format : AttributeFormat
        case
        when integer? then IntAttributeFormat.new(size, type.unsafe_as(IntAttributeFormat::Type), relative_offset)
        when float64? then Float64AttributeFormat.new(size, relative_offset)
        else               Float32AttributeFormat.new(size, type, normalized?, relative_offset)
        end
      end

      # Sets the format of the attribute.
      #
      # The data will be 32-bit floating-point values on the GPU.
      #
      # - OpenGL function: `glVertexArrayAttribFormat`
      # - OpenGL version: 4.5
      @[GLFunction("glVertexArrayAttribFormat", version: "4.5")]
      def format=(format : Float32AttributeFormat)
        float32_format(format.size, format.type, format.normalized?, format.relative_offset)
      end

      # Sets the format of the attribute.
      #
      # The data will be integer values on the GPU.
      #
      # - OpenGL function: `glVertexArrayAttribIFormat`
      # - OpenGL version: 4.5
      @[GLFunction("glVertexArrayAttribIFormat", version: "4.5")]
      def format=(format : IntAttributeFormat)
        int_format(format.size, format.type, format.relative_offset)
      end

      # Sets the format of the attribute.
      #
      # The data will be 64-bit floating-point values on the GPU.
      #
      # - OpenGL function: `glVertexArrayAttribLFormat`
      # - OpenGL version: 4.5
      @[GLFunction("glVertexArrayAttribLFormat", version: "4.5")]
      def format=(format : Float64AttributeFormat)
        float64_format(format.size, format.relative_offset, format.type)
      end
    end
  end
end
