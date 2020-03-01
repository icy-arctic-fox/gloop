module Gloop
  abstract struct StorageBuffer < Buffer
    def write(content, usage)
      checked { LibGL.named_buffer_storage(name, content.size, content, usage) }
    end

    def data=(content)
      checked { LibGL.named_buffer_storage(name, content.size, content, usage) }
    end

    # Usage pattern of the buffer.
    def usage
      value = checked { LibGL.get_named_buffer_parameter_iv(name, LibGL::BufferPNameARB::BufferStorageFlags, out usage) }
      LibGL::BufferStorageMask.from_value(value)
    end
  end
end
