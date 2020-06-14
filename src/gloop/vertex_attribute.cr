require "opengl"
require "./bool_conversion"
require "./error_handling"
require "./int_vertex_attribute_pointer"
require "./float_vertex_attribute_pointer"

module Gloop
  # References an attribute of a vertex.
  struct VertexAttribute
    include BoolConversion
    include ErrorHandling

    # Creates a getter method for an attribute parameter.
    # The *name* is the name of the method to define.
    # The *pname* is the enum value of the parameter to retrieve.
    # This should be an enum value from `LibGL::VertexAttribPropertyARB`.
    private macro parameter(name, pname)
      def {{name.id}}
        checked do
          LibGL.get_vertex_attrib_iv(index, LibGL::VertexAttribPropertyARB::{{pname.id}}, out param)
          param
        end
      end
    end

    # Creates a getter method for an attribute parameter that returns a boolean.
    # The *name* is the name of the method to define.
    # The method name will have `?` appended to it.
    # The *pname* is the enum value of the parameter to retrieve.
    # This should be an enum value from `LibGL::VertexAttribPropertyARB`.
    private macro parameter?(name, pname)
      def {{name.id}}?
        result = checked do
          LibGL.get_vertex_attrib_iv(index, LibGL::VertexAttribPropertyARB::{{pname.id}}, out param)
          param
        end
        int_to_bool(result)
      end
    end

    # Maximum index allowed for a vertex attribute.
    def self.max_index
      count - 1
    end

    # Maximum number of allowed vertex attributes.
    def self.count
      ErrorHandling.static_checked do
        LibGL.get_integer_v(LibGL::GetPName::MaxVertexAttribs, out result)
        result
      end
    end

    # Index of the vertex attribute.
    getter index : LibGL::UInt

    # Creates a reference to a vertex attribute.
    def initialize(index)
      @index = index.to_u32
    end

    # Index of the binding slot the attribute is bound to.
    private parameter binding_index, VertexAttribArrayBufferBinding

    # Retrieves the binding slot the attribute is bound to.
    def binding
      VertexBufferBinding.new(binding_index)
    end

    # Checks if the vertex attribute for the currently bound vertex array object (VAO) is enabled.
    parameter? enabled, VertexAttribArrayEnabled

    # Enables the vertex attribute for the currently bound vertex array object (VAO).
    def enable
      checked { LibGL.enable_vertex_attrib_array(index) }
    end

    # Disables the vertex attribute for the currently bound vertex array object (VAO).
    def disable
      checked { LibGL.disable_vertex_attrib_array(index) }
    end

    # Number of components in the attribute.
    # This can be 1, 2, 3, or 4.
    parameter size, VertexAttribArraySize

    # Number of bytes to the next attribute of this type.
    # A zero indicates the elements are stored sequentially in memory.
    parameter stride, VertexAttribArrayStride

    # Retrieves the OpenGL attribute type.
    private parameter type_value, VertexAttribArrayType

    # Indicates whether the format uses integers.
    parameter? integer, VertexAttribArrayInteger

    # Type of data contained in the attribute components.
    def type
      value = type_value
      if integer?
        IntVertexAttributeFormat::Type.new(value)
      else
        FloatVertexAttributeFormat::Type.new(value)
      end
    end

    # Indicates whether values stored as integers are mapped to the range [-1, 1] or [0, 1]
    # for signed and unsigned values respectively.
    parameter? normalized, VertexAttribArrayNormalized

    # Frequency divisor used for instanced rendering.
    parameter divisor, VertexAttribArrayDivisor

    # Byte offset from the first element relative to the start of the vertex buffer binding.
    parameter offset, VertexAttribRelativeOffset

    # Constructs the format information for this attribute.
    def format : VertexAttributeFormat
      if integer?
        IntVertexAttributeFormat.new(size, type.as(IntVertexAttributeFormat::Type))
      else
        FloatVertexAttributeFormat.new(size, type.as(FloatVertexAttributeFormat::Type), normalized?)
      end
    end

    # Constructs the format and pointer information for this attribute.
    def pointer : VertexAttributePointer
      if integer?
        IntVertexAttributePointer.new(size, type.as(IntVertexAttributeFormat::Type), stride, offset)
      else
        FloatVertexAttributePointer.new(size, type.as(FloatVertexAttributeFormat::Type), normalized?, stride, offset)
      end
    end

    # Sets the format of the vertex attribute.
    # Applies the format to the currently bound vertex array object (VAO).
    def pointer=(format : FloatVertexAttributePointer)
      normalized = bool_to_int(format.normalized?)
      pointer = Pointer(Void).new(format.offset)
      checked do
        LibGL.vertex_attrib_pointer(index, format.size, format.type, normalized, format.stride, pointer)
      end
    end

    # Sets the format of the vertex attribute.
    # Applies the format to the currently bound vertex array object (VAO).
    def pointer=(format : IntVertexAttributePointer)
      pointer = Pointer(Void).new(format.offset)
      checked do
        LibGL.vertex_attrib_i_pointer(index, format.size, format.type, format.stride, pointer)
      end
    end

    # Generates a string containing basic information about the vertex array attribute.
    # The string contains the vertex array attribute's index.
    def to_s(io)
      io << self.class
      io << '('
      io << index
      io << ')'
    end

    # Returns the OpenGL representation of the vertex attribute.
    def to_unsafe
      index
    end
  end
end
