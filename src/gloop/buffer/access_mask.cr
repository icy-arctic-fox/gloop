module Gloop
  struct Buffer < Object
    # Options for mapping a subset of a buffer.
    @[Flags]
    enum AccessMask : LibGL::Enum
      Read             = LibGL::MapBufferAccessMask::MapRead
      Write            = LibGL::MapBufferAccessMask::MapWrite
      InvalidateRange  = LibGL::MapBufferAccessMask::MapInvalidateRange
      InvalidateBuffer = LibGL::MapBufferAccessMask::MapInvalidateBuffer
      FlushExplicit    = LibGL::MapBufferAccessMask::MapFlushExplicit
      Unsynchronized   = LibGL::MapBufferAccessMask::MapUnsynchronized
      Persistent       = LibGL::MapBufferAccessMask::MapPersistent
      Coherent         = LibGL::MapBufferAccessMask::MapCoherent

      # Indicates whether the mapped data will be read-only with the selected flags.
      def read_only?
        read? && !write?
      end

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::MapBufferAccessMask.new(value)
      end
    end
  end
end
