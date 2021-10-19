require "./attribute_format"

module Gloop
  # Descriptor of a single-precision floating-point vertex attribute.
  struct Float32AttributeFormat < AttributeFormat
    # Enum indicating a attribute's type.
    enum Type : UInt32
      Int8    = LibGL::VertexAttribType::Byte
      UInt8   = LibGL::VertexAttribType::UnsignedByte
      Int16   = LibGL::VertexAttribType::Short
      UInt16  = LibGL::VertexAttribType::UnsignedShort
      Int32   = LibGL::VertexAttribType::Int
      UInt32  = LibGL::VertexAttribType::UnsignedInt
      Float32 = LibGL::VertexAttribType::Float
      Float64 = LibGL::VertexAttribType::Double

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexAttribType.new(value)
      end
    end

    # Type of data contained in the attribute.
    getter type : Type

    # Indicates an integer range is scaled to one-based range.
    getter? normalized : Bool

    # Creates the attribute format.
    def initialize(size : Int32, @type : Type, @normalized : Bool, relative_offset : UInt32)
      super(size, relative_offset)
    end
  end
end
