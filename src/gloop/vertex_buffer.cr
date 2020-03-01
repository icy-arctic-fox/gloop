require "opengl"
require "./buffer"

module Gloop
  struct VertexDataBuffer < DataBuffer
    def target
      LibGL::BufferTargetARB::ArrayBuffer
    end
  end

  struct VertexStorageBuffer < StorageBuffer
    def target
      LibGL::BufferStorageTarget::ArrayBuffer
    end
  end
end
