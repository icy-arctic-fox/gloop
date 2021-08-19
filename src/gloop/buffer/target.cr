module Gloop
  struct Buffer < Object
    # Targets a buffer can be bound to.
    enum Target : UInt32
      Array             = LibGL::BufferTargetARB::ArrayBuffer
      ElementArray      = LibGL::BufferTargetARB::ElementArrayBuffer
      PixelPack         = LibGL::BufferTargetARB::PixelPackBuffer
      PixelUnpack       = LibGL::BufferTargetARB::PixelUnpackBuffer
      TransformFeedback = LibGL::BufferTargetARB::TransformFeedbackBuffer
      Texture           = LibGL::BufferTargetARB::TextureBuffer
      CopyRead          = LibGL::BufferTargetARB::CopyReadBuffer
      CopyWrite         = LibGL::BufferTargetARB::CopyWriteBuffer
      Uniform           = LibGL::BufferTargetARB::UniformBuffer
      DrawIndirect      = LibGL::BufferTargetARB::DrawIndirectBuffer
      AtomicCounter     = LibGL::BufferTargetARB::AtomicCounterBuffer
      DispatchIndirect  = LibGL::BufferTargetARB::DispatchIndirectBuffer
      ShaderStorage     = LibGL::BufferTargetARB::ShaderStorageBuffer
      Query             = LibGL::BufferTargetARB::QueryBuffer
      Parameter         = LibGL::BufferTargetARB::ParameterBuffer

      # Binds the buffer to this target.
      def bind(buffer)
        buffer.bind(self)
      end

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::BufferTargetARB.new(value)
      end
    end
  end
end
