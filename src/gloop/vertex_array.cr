require "opengl"
require "./bool_conversion"
require "./error_handling"
require "./labelable"

module Gloop
  # Stores information about attributes and vertex buffers.
  struct VertexArray
    include BoolConversion
    include ErrorHandling
    include Labelable

    # Name of the vertex array object.
    getter name : LibGL::UInt

    # Associates with an existing vertex array object.
    private def initialize(@name)
    end

    # Creates a new vertex array object.
    def initialize
      @name = checked do
        LibGL.create_vertex_arrays(1, out name)
        name
      end
    end

    # Creates multiple vertex array objects at once.
    def self.create(count)
      names = Slice(LibGL::UInt).new(count)
      ErrorHandling.static_checked { LibGL.create_vertex_arrays(names.size, names) }
      names.map { |name| new(name) }
    end

    # Deletes multiple vertex arrays.
    def self.delete(arrays)
      # Retrieve underlying identifier for each vertex array.
      identifiers = arrays.map(&.to_unsafe)

      # Some enumerable types allow unsafe direct access to their internals.
      # If available, use that, as it is much faster.
      # Otherwise, convert to an array, which allows unsafe direct access.
      identifiers = identifiers.to_a unless identifiers.responds_to?(:to_unsafe)
      ErrorHandling.static_checked do
        LibGL.delete_vertex_arrays(identifiers.size, identifiers)
      end
    end

    # Binds the vertex array object to the current context.
    def bind
      checked { LibGL.bind_vertex_array(name) }
    end

    # Undbinds any previously bound vertex array object from the current context.
    def self.unbind
      ErrorHandling.static_checked { LibGL.bind_vertex_array(0) }
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

    # Namespace from which the name of the object is allocated.
    private def object_identifier : LibGL::ObjectIdentifier
      LibGL::ObjectIdentifier::VertexArray
    end
  end
end
