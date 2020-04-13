require "opengl"
require "./error_handling"

module Gloop
  enum BufferTarget : UInt32
    Array = LibGL::BufferTargetARB::ArrayBuffer

    ElementArray = LibGL::BufferTargetARB::ElementArrayBuffer

    PixelPack = LibGL::BufferTargetARB::PixelPackBuffer

    PixelUnpack = LibGL::BufferTargetARB::PixelUnpackBuffer

    TransformFeedback = LibGL::BufferTargetARB::TransformFeedbackBuffer

    Texture = LibGL::BufferTargetARB::TextureBuffer

    CopyRead = LibGL::BufferTargetARB::CopyReadBuffer

    CopyWrite = LibGL::BufferTargetARB::CopyWriteBuffer

    Uniform = LibGL::BufferTargetARB::UniformBuffer

    DrawIndirect = LibGL::BufferTargetARB::DrawIndirectBuffer

    AtomicCounter = LibGL::BufferTargetARB::AtomicCounterBuffer

    DispatchIndirect = LibGL::BufferTargetARB::DispatchIndirectBuffer

    ShaderStorage = LibGL::BufferTargetARB::ShaderStorageBuffer

    Query = LibGL::BufferTargetARB::QueryBuffer

    # Binds the specified buffer to the target.
    def bind(buffer)
      ErrorHandling.static_checked { LibGL.bind_buffer(value, buffer) }
    end

    # Retrieves the buffer currently bound to the target.
    # Returns nil if no buffer is bound.
    def current
      buffer = ErrorHandling.static_checked do
        LibGL.get_integer_v(value, out data)
        data
      end

      if current_storage?
        StorageBuffer.new(buffer)
      else
        DataBuffer.new(buffer)
      end
    end

    # Retrieves the entire contents of the buffer bound to the target.
    # Returns a slice of bytes.
    def data
      self[0, size]
    end

    # Updates the contents of the data buffer bound to the target.
    # The usage hint remains the same.
    # The *data* parameter must respond to `bytesize`
    # and return a pointer with `to_unsafe`.
    # The Slice (Bytes) type satisfies this.
    def data=(data)
      usage = ErrorHandling.static_checked do
        LibGL.get_buffer_parameter_iv(value, LibGL::VertexBufferObjectParameter::BufferUsage, out params)
        params
      end
      ErrorHandling.static_checked { LibGL.buffer_data(value, data.bytesize, data, usage) }
    end

    # Retrieves the usage hint given to OpenGL on how the immutable buffer will be used.
    def storage_usage
      value = ErrorHandling.static_checked do
        LibGL.get_buffer_parameter_iv(self.value, LibGL::VertexBufferObjectParameter::BufferUsage, out params)
        params
      end
      StorageBuffer::Usage.from_value(value)
    end

    # Updates the contents of the storage buffer bound to the target.
    # The usage hint remains the same.
    # The *data* parameter must respond to `bytesize`
    # and return a pointer with `to_unsafe`.
    # The Slice (Bytes) type satisfies this.
    def storage=(data)
      usage = ErrorHandling.static_checked do
        LibGL.get_buffer_parameter_iv(value, LibGL::VertexBufferObjectParameter::BufferStorageFlags, out params)
        params
      end
      ErrorHandling.static_checked { LibGL.buffer_storage(value, data.bytesize, data, usage) }
    end

    # Removes any previously bound buffer from the target.
    def unbind
      ErrorHandling.static_checked { LibGL.bind_buffer(value, 0) }
    end

    # Updates the contents of the buffer bound to the target.
    # The *data* parameter must respond to `bytesize`
    # and return a pointer with `to_unsafe`.
    # The Slice (Bytes) type satisfies this.
    def update_data(data, usage : DataBuffer::Usage)
      ErrorHandling.static_checked { LibGL.buffer_data(value, data.bytesize, data, usage) }
    end

    # Updates the contents of the buffer bound to the target.
    # The *data* parameter must respond to `bytesize`
    # and return a pointer with `to_unsafe`.
    # The Slice (Bytes) type satisfies this.
    def update_storage(data, usage : StorageBuffer::Usage)
      ErrorHandling.static_checked { LibGL.buffer_storage(value, data.bytesize, data, usage) }
    end

    # Retrieves the usage hint given to OpenGL on how the buffer will be used.
    def data_usage
      value = ErrorHandling.static_checked do
        LibGL.get_buffer_parameter_iv(self.value, LibGL::VertexBufferObjectParameter::BufferUsage, out params)
        params
      end
      DataBuffer::Usage.from_value(value)
    end

    # Retrieves a subset of the buffer's data.
    # Returns a slice of bytes.
    def [](range : Range)
      start, count = Indexable.range_to_index_and_count(range, size)
      self[start, count]
    end

    # Retrieves a subset of the buffer's data.
    # Returns a slice of bytes.
    def [](start : Int, count : Int)
      Bytes.new(count, read_only: true).tap do |slice|
        ErrorHandling.static_checked { LibGL.buffer_sub_data(value, start, count, slice) }
      end
    end

    # Updates a subset of the buffer's data.
    # The *content* should be a pointer or respond to `to_unsafe`, which returns a pointer.
    def []=(range : Range, content)
      start, count = Indexable.range_to_index_and_count(range, size)
      self[start, count] = content
    end

    # Updates a subset of the buffer's data.
    # The *content* should be a pointer or respond to `to_unsafe`, which returns a pointer.
    def []=(start : Int, count : Int, content)
      ErrorHandling.static_checked { LibGL.buffer_sub_data(value, start, count, content) }
    end

    # Checks if the currently bound buffer is immutable.
    private def current_storage?
      result = checked do
        LibGL.get_buffer_parameter_iv(value, LibGL::VertexBufferObjectParameter::BufferImmutableStorage, out params)
        params
      end
      int_to_bool(result)
    end
  end
end
