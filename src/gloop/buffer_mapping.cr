require "opengl"
require "./error_handling"

module Gloop
  # Provides access to a mapped region of a buffer's content.
  struct BufferMapping
    include ErrorHandling

    getter buffer_name

    protected def initialize(@buffer_name, @bytes : Bytes)
    end

    def unmap
      checked { LibGL.unmap_buffer(buffer_name) }
    end

    def to_unsafe
      raise NotImplementedError.new("#to_unsafe")
    end
  end
end
