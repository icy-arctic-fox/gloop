require "opengl"
require "./buffer"

module Gloop
  # Immutable buffer.
  # This buffer type has its size fixed, but can have its contents modified.
  struct StorageBuffer < Buffer
    # Creates a new, uninitialized buffer.
    # The data should be set manually with `#data=`.
    def initialize
      super
    end

    # Creates a new buffer of the specified size with undefined contents.
    def initialize(size : Int, usage = Usage::None)
      initialize
      checked { LibGL.named_buffer_storage(@buffer, size, nil, usage) }
    end

    # Creates a new buffer with initial contents.
    # The *data* parameter must respond to `bytesize`
    # and return a pointer with `to_unsafe`.
    # The Slice (Bytes) type satisfies this.
    def initialize(data, usage = Usage::None)
      initialize
      checked { LibGL.named_buffer_storage(@buffer, data.bytesize, data, usage) }
    end

    # Updates the contents of the buffer.
    # The usage hint remains the same.
    # The *data* parameter must respond to `bytesize`
    # and return a pointer with `to_unsafe`.
    # The Slice (Bytes) type satisfies this.
    def data=(data)
      usage = checked do
        LibGL.get_named_buffer_parameter_iv(@buffer, LibGL::VertexBufferObjectParameter::BufferStorageFlags, out params)
        params
      end
      checked { LibGL.named_buffer_storage(@buffer, data.bytesize, data, usage) }
    end

    # Updates the contents of the buffer.
    # The *data* parameter must respond to `bytesize` or `to_slice`
    # and return a pointer via `to_unsafe`.
    # The Slice (Bytes) and StaticArray types satisfy this.
    def update(data, usage)
      data = data.to_slice unless data.responds_to?(:bytesize)
      checked { LibGL.named_buffer_storage(@buffer, data.bytesize, data, usage) }
    end

    # Retrieves the usage hint given to OpenGL on how the buffer will be used.
    def usage
      value = checked do
        LibGL.get_named_buffer_parameter_iv(@buffer, LibGL::VertexBufferObjectParameter::BufferUsage, out params)
        params
      end
      Usage.from_value(value)
    end

    # Hint to OpenGL for how the buffer will be used.
    @[Flags]
    enum Usage : UInt32
      # Allows the contents of the buffer to updated after it has been created.
      Dynamic = LibGL::BufferStorageMask::DynamicStorage

      # Indicates that the buffer's contents should reside in application memory.
      Client = LibGL::BufferStorageMask::ClientStorage

      # Allows the buffer's contents to be read while it is mapped.
      MapRead = LibGL::BufferStorageMask::MapRead

      # Allows the buffer's contents to be modified while it is mapped.
      MapWrite = LibGL::BufferStorageMask::MapWrite

      # Allows the buffer to remain mapped while executing drawing or dispatch commands.
      MapPersistent = LibGL::BufferStorageMask::MapPersistent

      # Data written to the mapped region of a buffer is immediately visible to the server.
      # The mapping must be made with `#map_range`.
      MapCoherent = LibGL::BufferStorageMask::MapCoherent
    end
  end
end
