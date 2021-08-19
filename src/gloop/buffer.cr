require "./object"
require "./buffer/*"

module Gloop
  # GPU-hosted storage for arbitrary data.
  # See: https://www.khronos.org/opengl/wiki/Buffer_Object
  struct Buffer < Object
    extend ErrorHandling
    include ErrorHandling

    # Creates a new buffer.
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    def self.create
      name = checked do
        LibGL.create_buffers(1, out name)
        name
      end
      new(name)
    end

    # Creates multiple new buffers.
    # The number of buffers to create is given by *count*.
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    def self.create(count)
      names = Slice(UInt32).new(count)
      checked do
        LibGL.create_buffers(count, names)
      end
      names.map { |name| new(name) }
    end

    # Generates a new buffer.
    # This ensures a unique name for a buffer object.
    # Resources are not allocated for the buffer until it is bound.
    # See: `.create`
    def self.generate
      name = checked do
        LibGL.gen_buffers(1, out name)
        name
      end
      new(name)
    end

    # Generates multiple new buffers.
    # This ensures unique names for the buffer objects.
    # Resources are not allocated for the buffers until they are bound.
    # See: `.create`
    def self.generate(count)
      names = Slice(UInt32).new(count)
      checked do
        LibGL.gen_buffers(count, names)
      end
      names.map { |name| new(name) }
    end

    # Deletes multiple buffers.
    def self.delete(buffers)
      names = buffers.map(&.to_unsafe)
      count = names.size
      checked { LibGL.delete_buffers(count, names) }
    end

    # Deletes this buffer.
    def delete
      checked { LibGL.delete_buffers(1, pointerof(@name)) }
    end

    # Checks if the buffer is known by OpenGL.
    def exists?
      value = checked { LibGL.is_buffer(self) }
      !value.false?
    end

    # Indicates that this is a buffer object.
    def object_type
      Object::Type::Buffer
    end

    # Binds this buffer to the specified target.
    def bind(target : Target)
      checked { LibGL.bind_buffer(target, self) }
    end
  end
end
