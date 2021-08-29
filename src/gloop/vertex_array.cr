require "./error_handling"
require "./object"
require "./parameters"

module Gloop
  # Information about the specification of vertex formats.
  # See: https://www.khronos.org/opengl/wiki/Vertex_Specification#Vertex_Array_Object
  struct VertexArray < Object
    extend ErrorHandling
    extend Parameters
    include ErrorHandling

    # Retrieves the currently bound vertex array.
    # Returns nil if there isn't a vertex array bound.
    class_parameter VertexArrayBinding, current? do |name|
      new(name.to_u32!) unless name.zero?
    end

    # Retrieves the currently bound vertex array.
    # Returns `.none` if there isn't a vertex array bound.
    class_parameter VertexArrayBinding, current do |name|
      new(name.to_u32!)
    end

    # Creates a new vertex array.
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    def self.create
      name = checked do
        LibGL.create_vertex_arrays(1, out name)
        name
      end
      new(name)
    end

    # Creates multiple new vertex arrays.
    # The number of vertex arrays to create is given by *count*.
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    def self.create(count)
      names = Slice(UInt32).new(count)
      checked do
        LibGL.create_vertex_arrays(count, names)
      end
      names.map { |name| new(name) }
    end

    # Generates a new vertex array.
    # This ensures a unique name for a vertex array object.
    # Resources are not allocated for the vertex array until it is bound.
    # See: `.create`
    def self.generate
      name = checked do
        LibGL.gen_vertex_arrays(1, out name)
        name
      end
      new(name)
    end

    # Generates multiple new vertex arrays.
    # This ensures unique names for the vertex array objects.
    # Resources are not allocated for the vertex arrays until they are bound.
    # See: `.create`
    def self.generate(count)
      names = Slice(UInt32).new(count)
      checked do
        LibGL.gen_vertex_arrays(count, names)
      end
      names.map { |name| new(name) }
    end

    # Deletes multiple vertex arrays.
    def self.delete(vertex_arrays)
      names = vertex_arrays.map(&.to_unsafe)
      count = names.size
      checked { LibGL.delete_vertex_arrays(count, names) }
    end

    # Deletes this vertex array.
    def delete
      checked { LibGL.delete_vertex_arrays(1, pointerof(@name)) }
    end

    # Checks if the vertex array is known by OpenGL.
    def exists?
      value = checked { LibGL.is_vertex_array(self) }
      !value.false?
    end

    # Indicates that this is a vertex array object.
    def object_type
      Object::Type::VertexArray
    end

    # Binds this vertex array, making its vertex attributes active.
    def bind
      checked { LibGL.bind_vertex_array(self) }
    end

    # Binds this vertex array.
    # The previously bound vertex array (if any) is restored after the block exits.
    def bind
      previous = self.class.current
      bind

      begin
        yield
      ensure
        previous.bind
      end
    end

    # Removes any previously bound vertex buffers.
    def self.unbind
      checked { LibGL.bind_vertex_array(none) }
    end
  end
end
