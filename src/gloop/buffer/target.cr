module Gloop
  struct Buffer < Object
    # Targets a buffer can be bound to.
    enum Target : LibGL::Enum
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

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::BufferTargetARB.new(value)
      end

      # Returns an OpenGL enum representing this buffer binding target.
      # This intended to be used with `glCopyBufferSubData` since it uses a different enum group.
      protected def copy_buffer_target
        LibGL::CopyBufferSubDataTarget.new(value)
      end
    end
  end
end
