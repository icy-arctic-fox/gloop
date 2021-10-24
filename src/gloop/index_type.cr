module Gloop
  # Format of index values in element array buffers.
  enum IndexType : UInt32
    UInt8  = LibGL::DrawElementsType::UnsignedByte
    UInt16 = LibGL::DrawElementsType::UnsignedShort
    UInt32 = LibGL::DrawElementsType::UnsignedInt

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::DrawElementsType.new(value)
    end
  end
end
