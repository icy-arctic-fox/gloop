require "opengl"
require "./bool_conversion"
require "./error_handling"

module Gloop
  abstract struct Buffer
    include BoolConversion
    include ErrorHandling

    # Wraps an existing OpenGL buffer object.
    protected def initialize(@buffer : LibGL::UInt)
    end

    # Creates a new, empty buffer.
    protected def initialize
      @buffer = checked do
        LibGL.create_buffers(1, out buffer)
        buffer
      end
    end

    protected def self.create(count)
      buffers = Slice(LibGL::UInt).new(count)
      ErrorHandling.static_checked { LibGL.create_buffers(buffers.size, buffers) }
      buffers.map { |buffer| new(buffer) }
    end

    # Binds this buffer to the specified target.
    def bind(target)
      checked { LibGL.bind_buffer(target, @buffer) }
    end

    # Generates a string containing basic information about the buffer.
    # The string contains the buffer's identifier and type.
    def to_s(io)
      io << self.class
      io << '('
      io << @buffer
      io << ')'
    end

    # Retrieves the underlying identifier
    # that OpenGL uses to reference the buffer.
    def to_unsafe
      @buffer
    end
  end
end
