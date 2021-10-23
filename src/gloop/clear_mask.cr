module Gloop
  # Indicates buffers to clear.
  #
  # See: `RenderCommands#clear`
  @[Flags]
  enum ClearMask : UInt32
    Color   = LibGL::ClearBufferMask::ColorBuffer
    Depth   = LibGL::ClearBufferMask::DepthBuffer
    Stencil = LibGL::ClearBufferMask::StencilBuffer

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::ClearBufferMask.new(value)
    end
  end
end
