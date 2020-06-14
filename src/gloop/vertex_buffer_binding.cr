require "opengl"
require "./bool_conversion"
require "./error_handling"

module Gloop
  # Slot to bind a vertex buffer, vertex array, and vertex attributes against.
  struct VertexBufferBinding
    include BoolConversion
    include ErrorHandling

    # Maximum index allowed for vertex binding slots.
    def self.max_index
      count - 1
    end

    # Maximum number of vertex binding slots.
    def self.count
      ErrorHandling.static_checked do
        LibGL.get_integer_v(LibGL::GetPName::MaxVertexAttribBindings, out result)
        result
      end
    end

    # Index of the binding point.
    getter index : LibGL::UInt

    # Creates a reference to a vertex buffer binding slot.
    def initialize(index)
      @index = index.to_u32
    end

    # Binds a vertex attribute to the buffer slot.
    # Applies the attribute to the currently bound vertex array object (VAO).
    def attribute=(attribute)
      checked { LibGL.vertex_attrib_binding(attribute, index) }
    end

    # Binds a buffer to the slot.
    # The *offset* is the position in the buffer where the first element starts.
    # The *stride* is the distance between elements in the buffer.
    # This is typically the size (in bytes) of each vertex.
    # Applies the buffer binding to the currently bound vertex array object (VAO).
    def bind_buffer(buffer, offset, stride)
      checked { LibGL.bind_vertex_buffer(index, buffer, offset, stride) }
    end

    # Generates a string containing basic information about the vertex buffer binding.
    # The string contains the vertex buffer binding's index.
    def to_s(io)
      io << self.class
      io << '('
      io << index
      io << ')'
    end

    # Returns the OpenGL representation of the vertex buffer binding.
    def to_unsafe
      index
    end
  end
end
