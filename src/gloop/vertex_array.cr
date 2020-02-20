require "opengl"
require "./bool_conversion"
require "./error_handling"

module Gloop
  # Stores information about attributes and vertex buffers.
  struct VertexArray
    include BoolConversion
    include ErrorHandling

    # Name of the vertex array object.
    getter name : LibGL::UInt

    # Associates with an existing vertex array object.
    private def initialize(@name)
    end

    # Creates a new vertex array object.
    def initialize
      @name = checked do
        LibGL.gen_vertex_arrays(1, out name)
        name
      end
    end

    # Creates multiple vertex array objects at once.
    def self.create(count)
      names = Slice(LibGL::UInt).new(count)
      checked { LibGL.gen_vertex_arrays(names.size, names) }
      names.map { |name| new(name) }
    end

    # Binds the vertex array object to the current context.
    def bind
      checked { LibGL.bind_vertex_array(name) }
    end

    # Deletes the vertex array object and frees memory held by it.
    # Do not attempt to continue using the VAO after calling this method.
    def delete
      checked { LibGL.delete_vertex_arrays(1, pointerof(name)) }
    end

    # Checks if the vertex array object exists and has not been deleted.
    def exists?
      result = checked { LibGL.is_vertex_array(name) }
      int_to_bool(result)
    end

    # Generates a string containing basic information about the vertex array object.
    # The string contains the vertex array object's name.
    def to_s(io)
      io << self.class
      io << '('
      io << name
      io << ')'
    end

    # Retrieves the underlying name (identifier) used by OpenGL to reference the vertex array object.
    def to_unsafe
      name
    end
  end
end
