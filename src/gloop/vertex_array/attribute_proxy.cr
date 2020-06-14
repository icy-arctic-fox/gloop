require "opengl"
require "../bool_conversion"
require "../error_handling"
require "../float_vertex_attribute_format"
require "../float_vertex_attribute_pointer"
require "../int_vertex_attribute_format"
require "../int_vertex_attribute_pointer"

module Gloop
  struct VertexArray
    # Provides an intermediate interface to modify attributes associated with a vertex array.
    struct AttributeProxy
      include BoolConversion
      include ErrorHandling

      # Creates the proxy.
      # The *vao* is the OpenGL ID of the vertex array to proxy access to.
      # The *index* is the attribute index to proxy.
      protected def initialize(@vao : LibGL::UInt, @index : LibGL::UInt)
      end

      # Enables this attribute on this vertex array object.
      def enable
        checked { LibGL.enable_vertex_array_attrib(@vao, @index) }
      end

      # Disables this attribute on this vertex array object.
      def disable
        checked { LibGL.disable_vertex_array_attrib(@vao, @index) }
      end

      # Sets the format of this attribute on the vertex array object.
      def set_format(format : FloatVertexAttributeFormat, offset)
        type = LibGL::VertexAttribType.new(format.type.value)
        normalized = bool_to_int(format.normalized?)
        checked do
          LibGL.vertex_array_attrib_format(@vao, @index, format.size, type, normalized, offset)
        end
      end

      # Sets the format of this attribute on the vertex array object.
      def set_format(format : IntVertexAttributeFormat, offset)
        type = LibGL::VertexAttribType.new(format.type.value)
        checked do
          LibGL.vertex_array_attrib_i_format(@vao, @index, format.size, type, offset)
        end
      end

      # Sets the format of this attribute on the vertex array object.
      def format=(format : FloatVertexAttributePointer)
        type = LibGL::VertexAttribType.new(format.type.value)
        normalized = bool_to_int(format.normalized?)
        checked do
          LibGL.vertex_array_attrib_format(@vao, @index, format.size, type, normalized, format.offset)
        end
      end

      # Sets the format of this attribute on the vertex array object.
      def format=(format : IntVertexAttributePointer)
        type = LibGL::VertexAttribType.new(format.type.value)
        checked do
          LibGL.vertex_array_attrib_i_format(@vao, @index, format.size, type, format.offset)
        end
      end

      # Returns the OpenGL representation of the attribute (its index).
      def to_unsafe
        @index
      end
    end
  end
end
