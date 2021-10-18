require "./attribute_format"

module Gloop
  # Descriptor of a double-precision floating-point vertex attribute.
  struct Float64AttributeFormat < AttributeFormat
    # Enum indicating a attribute's type.
    enum Type : UInt32
      Float64 = LibGL::VertexAttribLType::Double

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexAttribLType.new(value)
      end
    end

    # Type of data contained in the attribute.
    def type : Type
      Type::Float64
    end
  end
end
