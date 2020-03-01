require "opengl"
require "./error_handling"

module Gloop
  # Base type for all buffers.
  abstract struct Buffer
    include ErrorHandling

    getter name : LibGL::UInt

    private def initialize(@name)
    end

    def initialize
      @name = checked do
        LibGL.create_buffers(1, out name)
        name
      end
    end

    def self.create(count)
      names = Slice(LibGL::UInt).new(count)
      ErrorHandling.static_checked { LibGL.create_buffers(names.size, names) }
      names.map { |name| new(name) }
    end
    
    abstract def target

    def bind
      checked { LibGL.bind_buffer(target, name) }
    end

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
