require "opengl"
require "./error_handling"

module Gloop
  enum BufferTarget < UInt32
    include ErrorHandling

    Array = LibGL::BufferTargetARB::ArrayBuffer

    ElementArray = LibGL::BufferTargetARB::ElementArrayBuffer

    PixelPack = LibGL::BufferTargetARB::PixelPackBuffer

    PixelUnpack = LibGL::BufferTargetARB::PixelUnpackBuffer

    TransformFeedback = LibGL::BufferTargetARB::TransformFeedbackBuffer

    Texture = LibGL::BufferTargetARB::TextureBuffer

    CopyRead = LibGL::BufferTargetARB::CopyReadBuffer

    CopyWrite = LibGL::BufferTargetARB::CopyWriteBuffer

    Uniform = LibGL::BufferTargetARB::UniformBuffer

    DrawIndirect = LibGL::BufferTargetARB::DrawIndirectBuffer

    AtomicCounter = LibGL::BufferTargetARB::AtomicCounterBuffer

    DispatchIndirect = LibGL::BufferTargetARB::DispatchIndirectBuffer

    ShaderStorage = LibGL::BufferTargetARB::ShaderStorageBuffer

    Query = LibGL::BufferTargetARB::QueryBuffer

    # Binds the specified buffer to the target.
    def bind(buffer)
      checked { LibGL.bind_buffer(value, buffer) }
    end

    # Removes any previously bound buffer from the target.
    def unbind
      checked { LibGL.bind_buffer(value, 0) }
    end
  end
end
