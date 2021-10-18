module Gloop
  # Base type for all attribute formats.
  #
  # Describes the format of data in an vertex attribute.
  abstract struct AttributeFormat
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

    # Number of components in the attribute.
    #
    # This is normally 1, 2, 3, or 4.
    getter size : Int32

    # Type of data contained in the attribute.
    getter type : Type

    # Relative offset of the attribute's data from the start of the buffer.
    getter offset : UInt32

    # Creates the attribute format.
    def initialize(@size : Int32, @type : Type, @offset : UInt32)
    end
  end
end
