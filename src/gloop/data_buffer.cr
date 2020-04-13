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
    # The *data* parameter must respond to `bytesize` or `to_slice`
    # and return a pointer via `to_unsafe`.
    # The Slice (Bytes) and StaticArray types satisfy this.
    def update(data, usage)
      data = data.to_slice unless data.responds_to?(:bytesize)
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
      StreamDraw = LibGL::VertexBufferObjectUsage::StreamDraw

      # The data store contents will be modified once and used at most a few times.
      # The data store contents are modified by reading data from OpenGL,
      # and used to return that data when queried by the application.
      StreamRead = LibGL::VertexBufferObjectUsage::StreamRead

      # The data store contents will be modified once and used at most a few times.
      # The data store contents are modified by reading from OpenGL,
      # and used as the source for OpenGL drawing and image specification commands.
      StreamCopy = LibGL::VertexBufferObjectUsage::StreamCopy

      # The data store contents will be modified once and used many times.
      # The data store contents are modified by the application,
      # and used as the source for OpenGL drawing and image specification commands.
      StaticDraw = LibGL::VertexBufferObjectUsage::StaticDraw

      # The data store contents will be modified once and used many times.
      # The data store contents are modified by reading data from OpenGL,
      # and used to return that data when queried by the application.
      StaticRead = LibGL::VertexBufferObjectUsage::StaticRead

      # The data store contents will be modified once and used many times.
      # The data store contents are modified by reading from OpenGL,
      # and used as the source for OpenGL drawing and image specification commands.
      StaticCopy = LibGL::VertexBufferObjectUsage::StaticCopy

      # The data store contents will be modified repeatedly and used many times.
      # The data store contents are modified by the application,
      # and used as the source for OpenGL drawing and image specification commands.
      DynamicDraw = LibGL::VertexBufferObjectUsage::DynamicDraw

      # The data store contents will be modified repeatedly and used many times.
      # The data store contents are modified by reading data from OpenGL,
      # and used to return that data when queried by the application.
      DynamicRead = LibGL::VertexBufferObjectUsage::DynamicRead

      # The data store contents will be modified repeatedly and used many times.
      # The data store contents are modified by reading from OpenGL,
      # and used as the source for OpenGL drawing and image specification commands.
      DynamicCopy = LibGL::VertexBufferObjectUsage::DynamicCopy

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::VertexBufferObjectUsage.new(value)
      end
    end
  end
end
