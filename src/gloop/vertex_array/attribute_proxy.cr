require "opengl"
require "../bool_conversion"
require "../error_handling"
require "../float_vertex_attribute_format"
require "../float_vertex_attribute_pointer"
require "../int_vertex_attribute_format"
require "../int_vertex_attribute_pointer"
require "../vertex_attribute_format"
require "../vertex_attribute_pointer"

module Gloop
  struct VertexArray
    # Provides an intermediate interface to modify attributes associated with a vertex array.
    struct AttributeProxy
      include BoolConversion
      include ErrorHandling

      # Creates a getter method for an attribute parameter.
      # The *name* is the name of the method to define.
      # The *pname* is the enum value of the parameter to retrieve.
      # This should be an enum value from `LibGL::VertexArrayPName`.
      private macro parameter(name, pname)
        def {{name.id}}
          checked do
            LibGL.get_vertex_array_indexed_iv(@vao, @index, LibGL::VertexArrayPName::{{pname.id}}, out param)
            param
          end
        end
      end

      # Creates a getter method for an attribute parameter that returns a boolean.
      # The *name* is the name of the method to define.
      # The method name will have `?` appended to it.
      # The *pname* is the enum value of the parameter to retrieve.
      # This should be an enum value from `LibGL::VertexArrayPName`.
      private macro parameter?(name, pname)
        def {{name.id}}?
          result = checked do
            LibGL.get_vertex_array_indexed_iv(@vao, @index, LibGL::VertexArrayPName::{{pname.id}}, out param)
            param
          end
          int_to_bool(result)
        end
      end

      # Creates the proxy.
      # The *vao* is the OpenGL ID of the vertex array to proxy access to.
      # The *index* is the attribute index to proxy.
      protected def initialize(@vao : LibGL::UInt, @index : LibGL::UInt)
      end

      # Checks if this attribute is enabled on the vertex array object.
      parameter? enabled, VertexAttribArrayEnabled

      # Enables this attribute on this vertex array object.
      def enable
        checked { LibGL.enable_vertex_array_attrib(@vao, @index) }
      end

      # Disables this attribute on this vertex array object.
      def disable
        checked { LibGL.disable_vertex_array_attrib(@vao, @index) }
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

      # Sets the format of this attribute on the vertex array object.
      def set_format(format : FloatVertexAttributeFormat, offset)
        type = LibGL::VertexAttribType.new(format.type.value)
        normalized = bool_to_int(format.normalized?)
        checked { LibGL.vertex_array_attrib_format(@vao, @index, format.size, type, normalized, offset) }
      end

      # Sets the format of this attribute on the vertex array object.
      def set_format(format : IntVertexAttributeFormat, offset)
        type = LibGL::VertexAttribType.new(format.type.value)
        checked { LibGL.vertex_array_attrib_i_format(@vao, @index, format.size, type, offset) }
      end

      # Constructs the format and pointer information for this attribute.
      def pointer : VertexAttributePointer
        if integer?
          IntVertexAttributePointer.new(size, type.as(IntVertexAttributeFormat::Type), stride, offset)
        else
          FloatVertexAttributePointer.new(size, type.as(FloatVertexAttributeFormat::Type), normalized?, stride, offset)
        end
      end

      # Sets the format of this attribute on the vertex array object.
      def pointer=(format : FloatVertexAttributePointer)
        type = LibGL::VertexAttribType.new(format.type.value)
        normalized = bool_to_int(format.normalized?)
        checked { LibGL.vertex_array_attrib_format(@vao, @index, format.size, type, normalized, format.offset) }
      end

      # Sets the format of this attribute on the vertex array object.
      def pointer=(format : IntVertexAttributePointer)
        type = LibGL::VertexAttribType.new(format.type.value)
        checked { LibGL.vertex_array_attrib_i_format(@vao, @index, format.size, type, format.offset) }
      end

      # Returns the OpenGL representation of the attribute (its index).
      def to_unsafe
        @index
      end
    end
  end
end
