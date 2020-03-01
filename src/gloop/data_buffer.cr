module Gloop
  abstract struct DataBuffer < Buffer
    def write(content, usage)
      checked { LibGL.named_buffer_data(name, content.size, content, usage) }
    end

    def data=(content)
      checked { LibGL.named_buffer_data(name, content.size, content, usage) }
    end

    # Usage pattern of the buffer.
    def usage
      value = checked { LibGL.get_named_buffer_parameter_iv(name, LibGL::BufferPNameARB::BufferUsage, out usage) }
      LibGL::VertexBufferObjectUsage.from_value(value)
    end
  end
end
