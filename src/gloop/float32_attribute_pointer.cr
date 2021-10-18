require "./attribute_pointer"

module Gloop
  # Descriptor of a single-precision floating-point vertex attribute.
  struct Float32AttributePointer < AttributePointer
    # Enum indicating a attribute's type.
    enum Type : UInt32
      Int8    = LibGL::VertexAttribPointerType::Byte
      UInt8   = LibGL::VertexAttribPointerType::UnsignedByte
      Int16   = LibGL::VertexAttribPointerType::Short
      UInt16  = LibGL::VertexAttribPointerType::UnsignedShort
      Int32   = LibGL::VertexAttribPointerType::Int
      UInt32  = LibGL::VertexAttribPointerType::UnsignedInt
      Float32 = LibGL::VertexAttribPointerType::Float
      Float64 = LibGL::VertexAttribPointerType::Double

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexAttribPointerType.new(value)
      end
    end

    # Type of data contained in the attribute.
    getter type : Type

    # Indicates an integer range is scaled to one-based range.
    getter? normalized : Bool

    # Creates the attribute format.
    def initialize(size : Int32, @type : Type, @normalized : Bool, stride : Int32 = 0, address : Size = 0)
      super(size, stride, address)
    end
  end
end
