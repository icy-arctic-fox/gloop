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

    # Retrieves the entire content of the buffer.
    # Returns a slice of bytes.
    def data
      self[0, size]
    end

    # Retrieves a subset of the buffer's data.
    # Returns a slice of bytes.
    def [](range : Range)
      start, count = Indexable.range_to_index_and_count(range, size)
      self[start, count]
    end

    # Retrieves a subset of the buffer's data.
    # Returns a slice of bytes.
    def [](start : Int, count : Int)
      Bytes.new(count).tap do |slice|
        checked { LibGL.get_named_buffer_sub_data(name, start, count, slice) }
      end
    end

    # Updates a subset of the buffer's data.
    # The *content* should be a pointer or respond to `to_unsafe`, which returns a pointer.
    def []=(range : Range, content)
      start, count = Indexable.range_to_index_and_count(range, size)
      self[start, count] = content
    end

    # Updates a subset of the buffer's data.
    # The *content* should be a pointer or respond to `to_unsafe`, which returns a pointer.
    def []=(start : Int, count : Int, content)
      checked { LibGL.named_buffer_sub_data(name, start, count, content) }
    end

    # Deletes the buffer object and frees memory held by it.
    # Do not attempt to continue using the buffer after calling this method.
    def delete
      checked { LibGL.delete_buffers(1, pointerof(name)) }
    end

    # Deletes multiple buffers and frees memory held by them.
    # Do not attempt to continue using the buffers after calling this method.
    def self.delete(buffers)
      names = buffers.map(&.to_unsafe)
      if names.responds_to?(:to_unsafe)
        checked { LibGL.delete_buffers(names.size, names) }
      else
        array = names.to_a
        checked { LibGL.delete_buffers(array.size, array) }
      end
    end

    # Copies the contents of one buffer to another.
    def self.copy(source, destination, source_offset, destination_offset, size)
      checked { LibGL.copy_named_buffer_sub_data(source, destination, source_offset, destination_offset, size) }
    end

    # Exposes the contents of the entire buffer.
    def map(*, access = LibGL::BufferAccessARB::ReadWrite)
      pointer = checked do
        LibGL.map_named_buffer(name, access)
      end
      slice = pointer.to_slice(size)
      BufferMapping.new(name, slice)
    end

    # Exposes the contents of the entire buffer.
    # The buffer is unmapped after the block finishes.
    def map(*, access = LibGL::BufferAccessARB::ReadWrite, &)
      map(access: access).tap do |mapping|
        yield mapping
      ensure
        mapping.unmap
      end
    end

    # Exposes a subset of the contents of the buffer.
    def map_range(offset, size, *, access = LibGL::BufferAccessARB::ReadWrite)
      pointer = checked do
        LibGL.map_named_buffer_range(name, offset, size, access)
      end
      slice = pointer.to_slice(size)
      BufferMapping.new(name, slice)
    end

    # Exposes a subset of the contents of the buffer.
    def map_range(range, *, access = LibGL::BufferAccessARB::ReadWrite)
      start, count = Indexable.range_to_index_and_count(range, size)
      map_range(start, count, access: access)
    end

    # Exposes a subset of the contents of the buffer.
    # The buffer is unmapped after the block finishes.
    def map_range(offset, size, *, access = LibGL::BufferAccessARB::ReadWrite, &)
      map_range(offset, size, access: access).tap do |mapping|
        yield mapping
      ensure
        mapping.unmap
      end
    end

    # Exposes a subset of the contents of the buffer.
    # The buffer is unmapped after the block finishes.
    def map_range(range, *, access = LibGL::BufferAccessARB::ReadWrite, &)
      map_range(range, access: access).tap do |mapping|
        yield mapping
      ensure
        mapping.unmap
      end
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
