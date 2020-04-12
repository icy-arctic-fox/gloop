require "opengl"
require "./buffer"

module Gloop
  # Mutable buffer.
  # This buffer type can have its size and contents modified dynamically.
  struct DataBuffer < Buffer
    # Creates a new, uninitialized buffer.
    # The data should be set manually with `#data=`.
    def initialize
      super
    end

    # Creates a new buffer of the specified size with undefined contents.
    def initialize(size : Int, usage = Usage::StaticDraw)
      initialize
      checked { LibGL.named_buffer_data(@buffer, size, nil, usage) }
    end

    # Creates a new buffer with initial contents.
    # The *data* parameter must respond to `bytesize`
    # and return a pointer with `to_unsafe`.
    # The Slice (Bytes) type satisfies this.
    def initialize(data, usage = Usage::StaticDraw)
      initialize
      checked { LibGL.named_buffer_data(@buffer, data.bytesize, data, usage) }
    end

    # Updates the contents of the buffer.
    # The usage hint remains the same.
    # The *data* parameter must respond to `bytesize`
    # and return a pointer with `to_unsafe`.
    # The Slice (Bytes) type satisfies this.
    def data=(data)
      usage = checked do
        LibGL.get_named_buffer_parameter_iv(@buffer, LibGL::VertexBufferObjectParameter::BufferUsage, out params)
        params
      end
      checked { LibGL.named_buffer_data(@buffer, data.bytesize, data, usage) }
    end

    # Updates the contents of the buffer.
    # The *data* parameter must respond to `bytesize`
    # and return a pointer with `to_unsafe`.
    # The Slice (Bytes) type satisfies this.
    def update(data, usage)
      checked { LibGL.named_buffer_data(@buffer, data.bytesize, data, usage) }
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
    enum Usage : UInt32
      # The data store contents will be modified once and used at most a few times.
      # The data store contents are modified by the application,
      # and used as the source for OpenGL drawing and image specification commands.
      StreamDraw = LibGL::BufferUsageARB::StreamDraw

      # The data store contents will be modified once and used at most a few times.
      # The data store contents are modified by reading data from OpenGL,
      # and used to return that data when queried by the application.
      StreamRead = LibGL::BufferUsageARB::StreamRead

      # The data store contents will be modified once and used at most a few times.
      # The data store contents are modified by reading from OpenGL,
      # and used as the source for OpenGL drawing and image specification commands.
      StreamCopy = LibGL::BufferUsageARB::StreamCopy

      # The data store contents will be modified once and used many times.
      # The data store contents are modified by the application,
      # and used as the source for OpenGL drawing and image specification commands.
      StaticDraw = LibGL::BufferUsageARB::StaticDraw

      # The data store contents will be modified once and used many times.
      # The data store contents are modified by reading data from OpenGL,
      # and used to return that data when queried by the application.
      StaticRead = LibGL::BufferUsageARB::StaticRead

      # The data store contents will be modified once and used many times.
      # The data store contents are modified by reading from OpenGL,
      # and used as the source for OpenGL drawing and image specification commands.
      StaticCopy = LibGL::BufferUsageARB::StaticCopy

      # The data store contents will be modified repeatedly and used many times.
      # The data store contents are modified by the application,
      # and used as the source for OpenGL drawing and image specification commands.
      DynamicDraw = LibGL::BufferUsageARB::DynamicDraw

      # The data store contents will be modified repeatedly and used many times.
      # The data store contents are modified by reading data from OpenGL,
      # and used to return that data when queried by the application.
      DynamicRead = LibGL::BufferUsageARB::DynamicRead

      # The data store contents will be modified repeatedly and used many times.
      # The data store contents are modified by reading from OpenGL,
      # and used as the source for OpenGL drawing and image specification commands.
      DynamicCopy = LibGL::BufferUsageARB::DynamicCopy
    end
  end
end
