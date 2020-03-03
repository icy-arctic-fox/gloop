require "opengl"
require "./storage_buffer"

module Gloop
  # Buffer with a fixed size intended for vetex data.
  struct VertexStorageBuffer < StorageBuffer
    # Binding target.
    private def target
      LibGL::BufferStorageTarget::ArrayBuffer
    end
  end
end
