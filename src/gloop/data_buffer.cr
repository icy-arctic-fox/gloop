module Gloop
  abstract struct DataBuffer < Buffer
    def write(content, usage)
      slice = if content.responds_to?(:to_slice)
        content.to_slice
      else
        content.to_a.to_slice
      end
      checked { LibGL.named_buffer_data(name, slice.bytesize, slice, usage) }
    end

    def data=(content)
      slice = if content.responds_to?(:to_slice)
        content.to_slice
      else
        content.to_a.to_slice
      end
      checked { LibGL.named_buffer_data(name, slice.bytesize, slice, usage) }
    end

    # Usage pattern of the buffer.
    def usage
      value = checked { LibGL.get_named_buffer_parameter_iv(name, LibGL::BufferPNameARB::BufferUsage, out usage) }
      LibGL::VertexBufferObjectUsage.from_value(value)
    end
  end
end
