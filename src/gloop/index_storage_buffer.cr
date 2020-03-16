require "opengl"
require "./storage_buffer"

module Gloop
  # Buffer with a fixed size intended for vetex indices.
  struct IndexStorageBuffer < StorageBuffer
    # Binding target.
    private def target
      LibGL::BufferStorageTarget::ElementArrayBuffer
    end
  end
end
