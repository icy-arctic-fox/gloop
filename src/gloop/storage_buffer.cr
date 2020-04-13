require "opengl"
require "./buffer"

module Gloop
  # Immutable buffer.
  # This buffer type has its size fixed, but can have its contents modified.
  struct StorageBuffer < Buffer
    # Creates a new, uninitialized buffer.
    # The data should be set manually with `#data=`.
    def initialize
      @buffer = create_buffer
    end

    # Creates a new buffer of the specified size with undefined contents.
    def initialize(size : Int, usage = Usage::None)
      @buffer = create_buffer
      checked { LibGL.named_buffer_storage(@buffer, size, nil, usage) }
    end

    # Creates a new buffer with initial contents.
    # The *data* parameter must respond to `to_a` or `to_slice`.
    # The Slice (Bytes) and StaticArray types satisfy this.
    def initialize(data, usage = Usage::None)
      @buffer = create_buffer
      slice = if data.responds_to?(:to_slice)
                data.to_slice
              else
                data.to_a.to_slice
              end
      checked { LibGL.named_buffer_storage(@buffer, slice.bytesize, slice, usage) }
    end

    # Updates the contents of the buffer.
    # The usage hint remains the same.
    # The *data* parameter must respond to `to_a` or `to_slice`.
    # The Slice (Bytes) and StaticArray types satisfy this.
    def data=(data)
      usage = checked do
        LibGL.get_named_buffer_parameter_iv(@buffer, LibGL::VertexBufferObjectParameter::BufferStorageFlags, out params)
        params
      end
      slice = if data.responds_to?(:to_slice)
                data.to_slice
              else
                data.to_a.to_slice
              end
      checked { LibGL.named_buffer_storage(@buffer, slice.bytesize, slice, usage) }
    end

    # Updates the contents of the buffer.
    # The *data* parameter must respond to `to_a` or `to_slice`.
    # The Slice (Bytes) and StaticArray types satisfy this.
    def update(data, usage)
      slice = if data.responds_to?(:to_slice)
                data.to_slice
              else
                data.to_a.to_slice
              end
      checked { LibGL.named_buffer_storage(@buffer, slice.bytesize, slice, usage) }
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

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::BufferStorageMask.new(value)
      end
    end
  end
end
