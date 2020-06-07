require "opengl"
require "./bool_conversion"
require "./buffer/*"
require "./error_handling"
require "./labelable"

module Gloop
  abstract struct Buffer
    include BoolConversion
    include ErrorHandling
    include Labelable

    # Creates a getter method for a buffer parameter.
    # The *name* is the name of the method to define.
    # The *pname* is the enum value of the parameter to retrieve.
    # This should be an enum value from `LibGL::VertexBufferObjectParameter`.
    private macro parameter(name, pname)
      def {{name.id}}
        checked do
          LibGL.get_named_buffer_parameter_iv(@buffer, LibGL::VertexBufferObjectParameter::{{pname.id}}, out params)
          params
        end
      end
    end

    # Creates a getter method for a buffer parameter.
    # This variant defines a method that returns a 64-bit integer.
    # The *name* is the name of the method to define.
    # The *pname* is the enum value of the parameter to retrieve.
    # This should be an enum value from `LibGL::VertexBufferObjectParameter`.
    private macro parameter64(name, pname)
      def {{name.id}}
        checked do
          LibGL.get_named_buffer_parameter_i64v(@buffer, LibGL::VertexBufferObjectParameter::{{pname.id}}, out params)
          params
        end
      end
    end

    # Creates a getter method for a buffer parameter that returns a boolean.
    # The *name* is the name of the method to define.
    # The method name will have `?` appended to it.
    # The *pname* is the enum value of the parameter to retrieve.
    # This should be an enum value from `LibGL::VertexBufferObjectParameter`.
    private macro parameter?(name, pname)
      def {{name.id}}?
        result = checked do
          LibGL.get_named_buffer_parameter_iv(@buffer, LibGL::VertexBufferObjectParameter::{{pname.id}}, out params)
          params
        end
        int_to_bool(result)
      end
    end

    # Indicates whether the buffer is currently mapped.
    parameter? mapped, BufferMapped

    # Retrieves the offset into the buffer (in bytes) where the mapping starts.
    # Returns zero if the buffer isn't mapped.
    parameter64 map_offset, BufferMapOffset

    # Retrieves the number of bytes from the buffer that are currently mapped.
    # Returns zero if the buffer isn't mapped.
    parameter64 map_size, BufferMapLength

    # Returns the size of the buffer in bytes.
    # Zero is returned if the buffer is uninitialized.
    parameter size, BufferSize

    # Indicates whether this buffer is "immutable."
    # Immutable means the buffer storage size is fixed,
    # however, the contents can still be modified.
    parameter? storage, BufferImmutableStorage

    # Wraps an existing OpenGL buffer object.
    protected def initialize(@buffer : LibGL::UInt)
    end

    # Copies one buffer to another.
    def self.copy(source, destination, source_offset, destination_offset, count)
      ErrorHandling.static_checked do
        LibGL.copy_named_buffer_sub_data(source, destination, source_offset, destination_offset, count)
      end
    end

    # Creates multiple buffers.
    protected def self.create(count)
      buffers = Slice(LibGL::UInt).new(count)
      ErrorHandling.static_checked { LibGL.create_buffers(buffers.size, buffers) }
      buffers.map { |buffer| new(buffer) }
    end

    # Deletes multiple buffers.
    def self.delete(buffers)
      # Retrieve underlying identifier for each buffer.
      identifiers = buffers.map(&.to_unsafe)

      # Some enumerable types allow unsafe direct access to their internals.
      # If available, use that, as it is much faster.
      # Otherwise, convert to an array, which allows unsafe direct access.
      identifiers = identifiers.to_a unless identifiers.responds_to?(:to_unsafe)
      ErrorHandling.static_checked do
        LibGL.delete_buffers(identifiers.size, identifiers)
      end
    end

    # Binds this buffer to the specified target.
    def bind(target)
      checked { LibGL.bind_buffer(target, @buffer) }
    end

    # Copies the contents of another buffer into this one.
    def copy_from(source, source_offset, destination_offset, count)
      Buffer.copy(source, self, source_offset, destination_offset, count)
    end

    # Copies the contents of this buffer into another one.
    def copy_to(destination, source_offset, destination_offset, count)
      Buffer.copy(self, destination, source_offset, destination_offset, count)
    end

    # Retrieves the entire contents of the buffer.
    # Returns a slice of bytes.
    def data
      self[0, size]
    end

    # Deletes the buffer object and frees memory held by it.
    # Do not attempt to continue using the buffer after calling this method.
    def delete
      checked { LibGL.delete_buffers(1, pointerof(@buffer)) }
    end

    # Checks if the buffer exists.
    def exists?
      result = expect_truthy { LibGL.is_buffer(@buffer) }
      int_to_bool(result)
    end

    # Invalidates all of the content in the buffer.
    # After invalidation, the content of the buffer is undefined.
    def invalidate
      checked { LibGL.invalidate_buffer_data(@buffer) }
    end

    # Invalidates a region of the content of the buffer.
    # After invalidation, the content of the specified range becomes undefined.
    def invalidate(range : Range)
      start, count = Indexable.range_to_index_and_count(range, size)
      invalidate(start, count)
    end

    # Invalidates a region of the content of the buffer.
    # After invalidation, the content of the specified range becomes undefined.
    def invalidate(start : Int, count : Int)
      checked { LibGL.invalidate_buffer_sub_data(@buffer, start, count) }
    end

    # Maps the entire buffer's content into the client application's memory.
    # The data can then be directly read and/or written,
    # depending on the specified *access* policy.
    # Returns a `Map` instance.
    def map(access : Map::Access)
      pointer = expect_truthy { LibGL.map_named_buffer(@buffer, access) }
      slice = Bytes.new(pointer.as(UInt8*), size, read_only: !access.write?)
      Map.new(@buffer, slice)
    end

    # Maps the entire buffer's content into the client application's memory.
    # The data can then be directly read and/or written,
    # depending on the specified *access* policy.
    # Yields a `Map` instance and returns the result of `#unmap`.
    # The buffer is automatically unmapped after the block completes,
    # even if an exception is raised.
    def map(access : Map::Access)
      map = map(access)
      begin
        yield map
      rescue e
        unmap
        raise e
      end
      unmap
    end

    # Maps part of the buffer's content into the client application's memory.
    # The data can then be directly read and/or written,
    # depending on the specified *access* policy.
    # Returns a `Map` instance.
    def map_range(range : Range, access : Map::Access)
      start, count = Indexable.range_to_index_and_count(range, size)
      map_range(start, count, access)
    end

    # Maps part of the buffer's content into the client application's memory.
    # The data can then be directly read and/or written,
    # depending on the specified *access* policy.
    # Yields a `Map` instance and returns the result of `#unmap`.
    # The buffer is automatically unmapped after the block completes,
    # even if an exception is raised.
    def map_range(range : Range, access : Map::Access)
      map = map_range(range, access)
      begin
        yield map
      rescue e
        unmap
        raise e
      end
      unmap
    end

    # Maps part of the buffer's content into the client application's memory.
    # The data can then be directly read and/or written,
    # depending on the specified *access* policy.
    # Returns a `Map` instance.
    def map_range(start : Int, count : Int, access : Map::Access)
      pointer = expect_truthy { LibGL.map_named_buffer_range(@buffer, start, count, access) }
      slice = Bytes.new(pointer.as(UInt8*), size, read_only: !access.write?)
      Map.new(@buffer, slice)
    end

    # Maps part of the buffer's content into the client application's memory.
    # The data can then be directly read and/or written,
    # depending on the specified *access* policy.
    # Yields a `Map` instance and returns the result of `#unmap`.
    # The buffer is automatically unmapped after the block completes,
    # even if an exception is raised.
    def map_range(start : Int, count : Int, access : Map::Access)
      map = map_range(start, count, access)
      begin
        yield map
      rescue e
        unmap
        raise e
      end
      unmap
    end

    # Retrieves the current mapping.
    # Returns a `Map` instance, or nil if there's no active mapping.
    def mapping
      pointer = expect_truthy do
        LibGL.get_named_buffer_pointer_v(@buffer, LibGL::BufferPointerNameARB::BufferMapPointer, out params)
        params
      end
      return unless pointer

      slice = Bytes.new(pointer.as(UInt8*), size, read_only: !map_access.write?)
      Map.new(@buffer, slice)
    end

    # Retrieves the access policy that was specified when the buffer was mapped with `#map`.
    def map_access
      value = checked do
        LibGL.get_named_buffer_parameter_iv(@buffer, LibGL::VertexBufferObjectParameter::BufferAccessFlags, out params)
        params
      end
      Map::Access.from_value(value)
    end

    # Generates a string containing basic information about the buffer.
    # The string contains the buffer's identifier and type.
    def to_s(io)
      io << self.class
      io << '('
      io << @buffer
      io << ')'
    end

    # Retrieves the underlying identifier
    # that OpenGL uses to reference the buffer.
    def to_unsafe
      @buffer
    end

    # Unmaps the buffer from the client application's memory.
    # Returns false if the buffer's contents have become corrupt while the buffer was mapped.
    def unmap
      value = expect_truthy { LibGL.unmap_named_buffer(@buffer) }
      int_to_bool(value)
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
      Bytes.new(count, read_only: true).tap do |slice|
        checked { LibGL.named_buffer_sub_data(@buffer, start, count, slice) }
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
      checked { LibGL.named_buffer_sub_data(@buffer, start, count, content) }
    end

    # Creates a single buffer object.
    private def create_buffer
      checked do
        LibGL.create_buffers(1, out buffer)
        buffer
      end
    end

    # Namespace from which the name of the object is allocated.
    private def object_identifier : LibGL::ObjectIdentifier
      LibGL::ObjectIdentifier::Buffer
    end
  end
end
