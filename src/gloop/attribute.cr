module Gloop
  # Base class for all attribute definitions.
  abstract struct Attribute
    # All valid attribute types.
    enum Type : LibGL::Enum
      Byte          = LibGL::VertexAttribPointerType::Byte
      UnsignedByte  = LibGL::VertexAttribPointerType::UnsignedByte
      Short         = LibGL::VertexAttribPointerType::Short
      UnsignedShort = LibGL::VertexAttribPointerType::UnsignedShort
      Int           = LibGL::VertexAttribPointerType::Int
      UnsignedInt   = LibGL::VertexAttribPointerType::UnsignedInt
      Float         = LibGL::VertexAttribPointerType::Float
      Double        = LibGL::VertexAttribPointerType::Double
      HalfFloat     = LibGL::VertexAttribPointerType::HalfFloat
      Fixed         = LibGL::VertexAttribPointerType::Fixed

      Int8    = Byte
      UInt8   = UnsignedByte
      Int16   = Short
      UInt16  = UnsignedShort
      Int32   = Int
      UInt32  = UnsignedInt
      Float16 = HalfFloat
      Float32 = Float
      Float64 = Double

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexAttribPointerType.new(value)
      end
    end

    # Number of components the attribute contains.
    getter size : Int32

    # Number of bytes from the start of a vertex's data to the attribute.
    getter offset : UInt32

    # Creates a new attribute definition.
    # The *size* refers to the number of components the attribute contains.
    # This must be 1, 2, 3, or 4.
    # The *offset* is the number of bytes from the start of a vertex's data to the attribute.
    def initialize(@size : Int32, @offset : UInt32)
    end

    # Applies this attribute definition to the specified index of a vertex array.
    abstract def apply(vao, index)

    # Applies this attribute definition to the specified index of the currently bound vertex array.
    abstract def apply(index)
  end
end
