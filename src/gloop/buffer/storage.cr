module Gloop
  struct Buffer < Object
    # Flags indicating how a buffer's immutable storage can be used.
    @[Flags]
    enum Storage : LibGL::Enum
      MapRead        = LibGL::BufferStorageMask::MapRead
      MapWrite       = LibGL::BufferStorageMask::MapWrite
      MapPersistent  = LibGL::BufferStorageMask::MapPersistent
      MapCoherent    = LibGL::BufferStorageMask::MapCoherent
      DynamicStorage = LibGL::BufferStorageMask::DynamicStorage
      ClientStorage  = LibGL::BufferStorageMask::ClientStorage

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::BufferStorageMask.new(value)
      end
    end
  end
end
