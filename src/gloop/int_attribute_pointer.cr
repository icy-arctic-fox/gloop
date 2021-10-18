require "./attribute_pointer"

module Gloop
  # Descriptor of an integer vertex attribute.
  struct IntAttributePointer < AttributePointer
    # Enum indicating a attribute's type.
    enum Type : UInt32
      Int8   = LibGL::VertexAttribIType::Byte
      UInt8  = LibGL::VertexAttribIType::UnsignedByte
      Int16  = LibGL::VertexAttribIType::Short
      UInt16 = LibGL::VertexAttribIType::UnsignedShort
      Int32  = LibGL::VertexAttribIType::Int
      UInt32 = LibGL::VertexAttribIType::UnsignedInt

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexAttribIType.new(value)
      end
    end

    # Type of data contained in the attribute.
    getter type : Type

    # Creates a descriptor of the attribute's format.
    def initialize(size : Int32, @type : Type, stride : Int32 = 0, address : Size = 0)
      super(size, stride, address)
    end
  end
end
