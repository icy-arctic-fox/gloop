module Gloop
  struct Buffer < Object
    # Buffer mapping access settings.
    # Determines whether the mapped data can be read, written, or both.
    enum Access : UInt32
      ReadOnly  = LibGL::BufferAccessARB::ReadOnly
      WriteOnly = LibGL::BufferAccessARB::WriteOnly
      ReadWrite = LibGL::BufferAccessARB::ReadWrite

      Read  = ReadOnly
      Write = WriteOnly

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::BufferAccessARB.new(value)
      end
    end
  end
end
