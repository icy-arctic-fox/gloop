require "opengl"
require "./data_buffer"

module Gloop
  # Buffer with a dynamic size intended for vetex indices.
  struct IndexDataBuffer < DataBuffer
    # Binding target.
    private def target
      LibGL::BufferTargetARB::ElementArrayBuffer
    end
  end
end
