require "../attribute"
require "../error_handling"
require "../float32_attribute"
require "../float64_attribute"
require "../int32_attribute"

module Gloop
  struct VertexArray < Object
    # Reference to an attribute associated with a vertex array.
    struct AttributeIndex
      include ErrorHandling

      # Defines a getter method that retrieves an OpenGL vertex array attribute parameter.
      # The *pname* is the name of the OpenGL parameter to retrieve.
      # This should be an enum value (just the name) from `LibGL::VertexArrayPName`.
      # The *name* will be the name of the generated method.
      #
      # ```
      # attribute_parameter VertexAttribArraySize, size
      # ```
      #
      # The `#vao` method is used to get the vertex array name.
      # The `#index` method is used to get the attribute index.
      #
      # An optional block can be provided to modify the value before returning it.
      # The original value is yielded to the block.
      private macro attribute_parameter(pname, name, &block)
        def {{name.id}}
          %value = checked do
            LibGL.get_vertex_array_indexed_iv(vao, index, LibGL::VertexArrayPName::{{pname.id}}, out value)
            value
          end

          {% if block %}
            {{block.args.splat}} = %value
            {{yield}}
          {% end %}
        end
      end

      # Defines a boolean getter method that retrieves an OpenGL vertex array attribute parameter.
      # The *pname* is the OpenGL parameter name to retrieve.
      # This should be an enum value (just the name) from `LibGL::VertexArrayPName`.
      # The *name* will be the name of the generated method, with a question mark appended to it.
      #
      # ```
      # attribute_parameter? VertexAttribArrayEnabled, enabled
      # ```
      #
      # The `#vao` method is used to get the vertex array name.
      # The `#index` method is used to get the attribute index.
      private macro attribute_parameter?(pname, name)
        def {{name.id}}? : Bool
          checked do
            LibGL.get_vertex_array_indexed_iv(vao, index, LibGL::VertexArrayPName::{{pname.id}}, out value)
            !value.zero?
          end
        end
      end

      # Indicates whether this attribute is enabled or not.
      # When enabled, vertex data for this attribute is pulled from a buffer.
      attribute_parameter? VertexAttribArrayEnabled, enabled

      # Number of components this attribute has.
      # This will be 1, 2, 3, or 4.
      attribute_parameter VertexAttribArraySize, size

      # Number of bytes between sucessive elements of the same attribute.
      attribute_parameter VertexAttribArrayStride, stride

      # Type of a single component of the attribute.
      attribute_parameter VertexAttribArrayType, type do |value|
        Attribute::Type.new(value.to_u32!)
      end

      # Indicates whether fixed-point data types used by this attribute are normalized.
      attribute_parameter? VertexAttribArrayNormalized, normalized

      # Indicates whether the data type used by this attribute is integer-based.
      attribute_parameter? VertexAttribArrayInteger, integer

      # Indicates whether the data type used by this attribute is a 64-bit floating-point number.
      attribute_parameter? VertexAttribArrayLong, long

      # Frequency the divisor is updated when using instanced rendering.
      attribute_parameter VertexAttribArrayDivisor, divisor

      # Offset (in bytes) to the first element relative to the start of the bound vertex buffer.
      attribute_parameter VertexAttribRelativeOffset, offset, &.to_u32!

      # Name of the vertex array.
      private getter vao : UInt32

      # Index of the attribute in the vertex array.
      getter index : UInt32

      # Creates a reference to a vertex array's attribute.
      def initialize(@vao : UInt32, @index : UInt32)
      end

      # Enables this attribute on the vertex array.
      def enable
        checked { LibGL.enable_vertex_array_attrib(@vao, @index) }
      end

      # Disables this attribute on the vertex array.
      def disable
        checked { LibGL.disable_vertex_array_attrib(@vao, @index) }
      end

      # Enables or disables this attribute on the vertex array.
      def enabled=(flag)
        flag ? enable : disable
      end

      # Offset (in bytes) to the first attribute in the vertex buffer data.
      def buffer_offset : UInt64
        pname = LibGL::VertexArrayPName.new(LibGL::GetPName::VertexBindingOffset.value)
        checked do
          LibGL.get_vertex_array_indexed_64iv(vao, index, pname, out value)
          value.to_u64!
        end
      end

      # Offset to the start of attribute data in the vertex buffer.
      def pointer : Pointer(Void)
        Pointer(Void).new(buffer_offset)
      end

      # Retrieves a definition for this attribute that can be assigned to other indexes.
      def definition : Attribute
        case
        when integer? then Int32Attribute.new(size, type.unsafe_as(Int32Attribute::Type), offset)
        when long?    then Float64Attribute.new(size, type.unsafe_as(Float64Attribute::Type), offset)
        else               Float32Attribute.new(size, type.unsafe_as(Float32Attribute::Type), normalized?, offset)
        end
      end
    end
  end
end
