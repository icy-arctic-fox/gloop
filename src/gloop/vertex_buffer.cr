require "opengl"
require "./buffer"

module Gloop
  struct VertexDataBuffer(T) < DataBuffer(T)
    def target
      LibGL::BufferTargetARB::ArrayBuffer
    end
  end

  struct VertexStorageBuffer(T) < StorageBuffer(T)
    def target
      LibGL::BufferStorageTarget::ArrayBuffer
    end
  end
end
