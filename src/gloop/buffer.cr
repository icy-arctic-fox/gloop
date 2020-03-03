require "opengl"
require "./bool_conversion"
require "./error_handling"

module Gloop
  # Base type for all buffers.
  abstract struct Buffer
    include BoolConversion
    include ErrorHandling

    # Name of the buffer.
    # Used to reference the buffer.
    getter name : LibGL::UInt

    # Wraps an existing buffer.
    private def initialize(@name)
    end

    # Creates an empty buffer.
    def initialize
      @name = checked do
        LibGL.create_buffers(1, out name)
        name
      end
    end

    # Creates the specified number of buffers.
    def self.create(count)
      names = Slice(LibGL::UInt).new(count)
      ErrorHandling.static_checked { LibGL.create_buffers(names.size, names) }
      names.map { |name| new(name) }
    end

    # Binding target.
    private abstract def target

    # Assigns the buffer to its corresponding target in the current context.
    def bind
      checked { LibGL.bind_buffer(target, name) }
    end

    # Unbinds any buffer of the corresponding target.
    def self.unbind
      ErrorHandling.static_checked { LibGL.bind_buffer(target, 0) }
    end

    # Size of the buffer object in bytes.
    def size
      checked do
        LibGL.get_named_buffer_parameter_iv(name, LibGL::BufferPNameARB::BufferSize, out size)
        size
      end
    end

    # Deletes the buffer object and frees memory held by it.
    # Do not attempt to continue using the buffer after calling this method.
    def delete
      checked { LibGL.delete_buffers(1, pointerof(name)) }
    end

    # Checks if the buffer object exists and has not been deleted.
    def exists?
      result = checked { LibGL.is_buffer(name) }
      int_to_bool(result)
    end

    # Generates a string containing basic information about the buffer.
    # The string contains the buffer's name and type.
    def to_s(io)
      io << self.class
      io << '('
      io << name
      io << ')'
    end

    # Retrieves the underlying name (identifier) used by OpenGL to reference the buffer.
    def to_unsafe
      name
    end
  end
end
