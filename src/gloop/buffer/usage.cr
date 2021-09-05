module Gloop
  struct Buffer < Object
    # Hints indicating how a buffer's data will be used.
    enum Usage : LibGL::Enum
      StreamDraw  = LibGL::VertexBufferObjectUsage::StreamDraw
      StreamRead  = LibGL::VertexBufferObjectUsage::StreamRead
      StreamCopy  = LibGL::VertexBufferObjectUsage::StreamCopy
      StaticDraw  = LibGL::VertexBufferObjectUsage::StaticDraw
      StaticRead  = LibGL::VertexBufferObjectUsage::StaticRead
      StaticCopy  = LibGL::VertexBufferObjectUsage::StaticCopy
      DynamicDraw = LibGL::VertexBufferObjectUsage::DynamicDraw
      DynamicRead = LibGL::VertexBufferObjectUsage::DynamicRead
      DynamicCopy = LibGL::VertexBufferObjectUsage::DynamicCopy

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::BufferUsageARB.new(value)
      end

      # Converts to an OpenGL enum.
      #
      # For some reason, the OpenGL API specifies some "named" variant methods
      # with `VertexBufferObjectUsage` instead of `BufferUsageARB`.
      # They're literally the same underlying values, but in a different enum group.
      protected def named_to_unsafe
        LibGL::VertexBufferObjectUsage.new(value)
      end
    end
  end
end
