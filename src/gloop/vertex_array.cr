require "opengl"
require "./bool_conversion"
require "./error_handling"
require "./float_vertex_attribute_format"
require "./float_vertex_attribute_pointer"
require "./int_vertex_attribute_format"
require "./int_vertex_attribute_pointer"
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

    # Retrieves the currently bound vertex array.
    def self.current
      name = checked do
        LibGL.get_integer_v(LibGL::PName::VertexArrayBinding, out result)
        result
      end
      new(name)
    end

    # Binds the vertex array object to the current context.
    def bind
      checked { LibGL.bind_vertex_array(name) }
    end

    # Binds this vertex array for the duration of the block.
    # The previously bound vertex array is rebound after the block completes (even if an error is raised).
    def bind(&)
      previous = self.class.current
      begin
        bind
        yield
      ensure
        previous.bind
      end
    end

    # Undbinds any previously bound vertex array object from the current context.
    def self.unbind
      ErrorHandling.static_checked { LibGL.bind_vertex_array(0) }
    end

    # Deletes the vertex array object and frees memory held by it.
    # Do not attempt to continue using the VAO after calling this method.
    def delete
      checked { LibGL.delete_vertex_arrays(1, pointerof(@name)) }
    end

    # Checks if the vertex array object exists and has not been deleted.
    def exists?
      result = checked { LibGL.is_vertex_array(name) }
      int_to_bool(result)
    end

    # Specifies the element (index) buffer to use.
    def element_buffer=(buffer)
      checked { LibGL.vertex_array_element_buffer(name, buffer) }
    end

    # Provides access to all attributes associated with the vertex array.
    def attributes : AttributeCollection
      AttributeCollection.new(name)
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

    # Provides an intermediate interface to access attributes attached to the vertex array.
    struct AttributeCollection
      # Creates the collection.
      # The *vao* should be the OpenGL ID of the vertex array to proxy access to.
      protected def initialize(@vao : LibGL::UInt)
      end

      # Retrieves the attribute with the specified index.
      def [](index) : AttributeProxy
        AttributeProxy.new(@vao, index.to_u32)
      end
    end

    # Provides an intermediate interface to modify attributes associated with a vertex array.
    struct AttributeProxy
      include BoolConversion
      include ErrorHandling

      # Creates the proxy.
      # The *vao* is the OpenGL ID of the vertex array to proxy access to.
      # The *index* is the attribute index to proxy.
      protected def initialize(@vao : LibGL::UInt, @index : LibGL::UInt)
      end

      # Enables this attribute on this vertex array object.
      def enable
        checked { LibGL.enable_vertex_array_attrib(@vao, @index) }
      end

      # Disables this attribute on this vertex array object.
      def disable
        checked { LibGL.disable_vertex_array_attrib(@vao, @index) }
      end

      # Sets the format of this attribute on the vertex array object.
      def set_format(format : FloatVertexAttributeFormat, offset)
        type = LibGL::VertexAttribType.new(format.type.value)
        normalized = bool_to_int(format.normalized?)
        checked do
          LibGL.vertex_array_attrib_format(@vao, @index, format.size, type, normalized, offset)
        end
      end

      # Sets the format of this attribute on the vertex array object.
      def set_format(format : IntVertexAttributeFormat, offset)
        type = LibGL::VertexAttribType.new(format.type.value)
        checked do
          LibGL.vertex_array_attrib_i_format(@vao, @index, format.size, type, offset)
        end
      end

      # Sets the format of this attribute on the vertex array object.
      def format=(format : FloatVertexAttributePointer)
        type = LibGL::VertexAttribType.new(format.type.value)
        normalized = bool_to_int(format.normalized?)
        checked do
          LibGL.vertex_array_attrib_format(@vao, @index, format.size, type, normalized, format.offset)
        end
      end

      # Sets the format of this attribute on the vertex array object.
      def format=(format : IntVertexAttributePointer)
        type = LibGL::VertexAttribType.new(format.type.value)
        checked do
          LibGL.vertex_array_attrib_i_format(@vao, @index, format.size, type, format.offset)
        end
      end
    end
  end
end
