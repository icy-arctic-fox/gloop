require "opengl"
require "./bool_conversion"
require "./error_handling"

module Gloop
  # References an attribute of a vertex.
  struct VertexAttribute
    include BoolConversion
    include ErrorHandling

    # Maximum index allowed for a vertex attribute.
    def self.max_index
      count - 1
    end

    # Maximum number of allowed vertex attributes.
    def self.count
      ErrorHandling.static_check do
        LibGL.get_integer_v(LibGL::PName::MaxVertexAttribs, out result)
        result
      end
    end

    # Index of the vertex attribute.
    getter index : LibGL::UInt

    # Creates a reference to a vertex attribute.
    def initialize(@index)
    end

    # Enables the vertex attribute for the currently bound vertex array object (VAO).
    def enable
      checked { LibGL.enable_vertex_attrib_array(index) }
    end

    # Disables the vertex attribute for the currently bound vertex array object (VAO).
    def disable
      checked { LibGL.disable_vertex_attrib_array(index) }
    end

    # Checks if the vertex attribute for the currently bound vertex array object (VAO) is enabled.
    def enabled?
      value = checked do
        LibGL.get_vertex_attrib_iv(index, LibGL::VertexAttribPropertyARB::VertexAttribArrayEnabled, out result)
        result
      end
      int_to_bool(value)
    end

    # Generates a string containing basic information about the vertex array attribute.
    # The string contains the vertex array attribute's index.
    def to_s(io)
      io << self.class
      io << '('
      io << index
      io << ')'
    end

    # Returns the OpenGL representation of the vertex attribute.
    def to_unsafe
      index
    end
  end
end
