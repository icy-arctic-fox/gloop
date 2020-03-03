require "opengl"
require "./data_buffer"

module Gloop
  # Buffer with a dynamic size intended for vetex data.
  struct VertexDataBuffer < DataBuffer
    # Binding target.
    private def target
      LibGL::BufferTargetARB::ArrayBuffer
    end
  end
end
