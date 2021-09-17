require "./object"
require "./buffer/*"

module Gloop
  # GPU-hosted storage for arbitrary data.
  # See: https://www.khronos.org/opengl/wiki/Buffer_Object
  struct Buffer < Object
    include BufferParameters
    extend ErrorHandling
    include ErrorHandling

    # Indicates whether the buffer is immutable.
    buffer_parameter? BufferImmutableStorage, immutable

    # Indicates whether the buffer is currently mapped.
    buffer_parameter? BufferMapped, mapped

    # Size of the buffer's contents in bytes.
    buffer_parameter BufferSize, size

    # Retrieves the flags previously set for the buffer's immutable storage.
    # See: `#storage`
    buffer_parameter BufferStorageFlags, storage_flags do |value|
      Storage.new(value.to_u32)
    end

    # Retrieves the usage hints previously provided for the buffer's data.
    # See: `#data`
    buffer_parameter BufferUsage, usage do |value|
      Usage.new(value.to_u32)
    end

    # Creates a new buffer.
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    def self.create(context)
      name = uninitialized UInt32
      gl_call context, create_buffers(1, pointerof(name))
      new(context, name)
    end

    # Creates multiple new buffers.
    # The number of buffers to create is given by *count*.
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    def self.create(context, count)
      names = Slice(UInt32).new(count)
      gl_call context, create_buffers(count, names.to_unsafe)
      names.map { |name| new(context, name) }
    end

    # Generates a new buffer.
    # This ensures a unique name for a buffer object.
    # Resources are not allocated for the buffer until it is bound.
    # See: `.create`
    def self.generate(context)
      name = uninitialized UInt32
      gl_call context, gen_buffers(1, pointerof(name))
      new(context, name)
    end

    # Generates multiple new buffers.
    # This ensures unique names for the buffer objects.
    # Resources are not allocated for the buffers until they are bound.
    # See: `.create`
    def self.generate(context, count)
      names = Slice(UInt32).new(count)
      gl_call context, gen_buffers(count, names.to_unsafe)
      names.map { |name| new(context, name) }
    end

    # Creates a mutable buffer with initial contents.
    # This effectively combines `.create` and `#data`.
    def self.mutable(context, data, usage : Usage = :static_draw)
      create(context).tap do |buffer|
        buffer.data(data, usage)
      end
    end

    # Creates an immutable buffer with initial contents.
    # This effectively combines `.create` and `#storage`.
    def self.immutable(context, data, flags : Storage)
      create(context).tap do |buffer|
        buffer.storage(data, flags)
      end
    end

    # TODO: Delete multiple

    # Deletes this buffer.
    def delete
      gl_call delete_buffers(1, pointerof(@name))
    end

    # Checks if the buffer is known by OpenGL.
    def exists?
      value = gl_call is_buffer(name)
      !value.false?
    end

    # Indicates that this is a buffer object.
    def object_type
      Object::Type::Buffer
    end

    # Binds this buffer to the specified target.
    def bind(target : Target | BindTarget)
      gl_call bind_buffer(target.to_unsafe, name)
    end

    # Binds this buffer to the specified target.
    # The previously bound buffer (if any) is restored after the block exits.
    def bind(target : Target)
      target = BindTarget.new(context, target)
      bind(target) { yield }
    end

    # Binds this buffer to the specified target.
    # The previously bound buffer (if any) is restored after the block exits.
    def bind(target : BindTarget)
      previous = target.buffer
      target.bind(self)

      begin
        yield
      ensure
        target.bind(previous)
      end
    end

    # Stores data in this buffer.
    # The *data* must have a `#to_slice` method.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    def data(data, usage : Usage = :static_draw)
      slice = data.to_slice
      pointer = slice.to_unsafe.as(Void*)
      size = slice.bytesize.to_i64
      gl_call named_buffer_data(name, size, pointer, usage.named_to_unsafe)
    end

    # Initializes the buffer of a given size with undefined contents.
    def allocate_data(size : Int64, usage : Usage = :static_draw)
      gl_call named_buffer_data(name, size, nil, usage.named_to_unsafe)
    end

    # Stores data in this buffer.
    # The *data* must have a `#to_slice` method.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    # Previously set `#usage` hint is reapplied for this data.
    def data=(data)
      self.data(data, usage)
    end

    # Retrieves all data in the buffer.
    def data
      Bytes.new(size).tap do |bytes|
        gl_call get_named_buffer_sub_data(name, 0_i64, bytes.bytesize.to_i64, bytes.to_unsafe.as(Void*))
      end
    end

    # Stores data in this buffer.
    # This makes the buffer have a fixed size (immutable).
    # The *data* must have a `#to_slice` method.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    def storage(data, flags : Storage)
      slice = data.to_slice
      pointer = slice.to_unsafe.as(Void*)
      size = slice.bytesize.to_i64
      gl_call named_buffer_storage(name, size, pointer, flags.to_unsafe)
    end

    # Initializes the buffer of a given size with undefined contents.
    # This makes the buffer have a fixed size (immutable).
    def allocate_storage(size : Int64, flags : Storage)
      gl_call named_buffer_storage(name, size, nil, flags)
    end

    # Retrieves a subset of data from the buffer.
    def []?(start : Int, count : Int) : Bytes?
      start, count = Indexable.normalize_start_and_count(start, count, size) { return nil }
      Bytes.new(count).tap do |bytes|
        gl_call get_named_buffer_sub_data(name, start, count, bytes)
      end
    end

    # Retrieves a subset of data from the buffer.
    def [](start : Int, count : Int) : Bytes
      self[start, count]? || raise IndexError.new
    end

    # Retrieves a range of data from the buffer.
    def []?(range : Range) : Bytes?
      size = self.size
      start, count = Indexable.range_to_index_and_count(range, size) || return nil
      start, count = Indexable.normalize_start_and_count(start, count, size) { return nil }
      Bytes.new(count).tap do |bytes|
        gl_call get_named_buffer_sub_data(name, start, count, bytes)
      end
    end

    # Retrieves a range of data from the buffer.
    def [](range : Range) : Bytes
      self[range]? || raise IndexError.new
    end

    # Updates a subset of the buffer's data store.
    # The number of bytes updated in the buffer is equal to the byte-size of *data*.
    # The *data* must have a `#to_slice`.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    def update(offset : Int, data)
      slice = data.to_slice
      self[offset, slice.bytesize] = slice
    end

    # Updates a subset of the buffer's data store.
    # The *data* must have a `#to_unsafe` method or be a `Pointer`.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    #
    # NOTE: Any length *data* might have is ignored.
    # Be sure that *count* is less than or equal to the byte-size length of *data*.
    def []=(start : Int, count : Int, data)
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      gl_call named_buffer_sub_data(name, start, count, data)
    end

    # Updates a subset of the buffer's data store.
    # The *data* must have a `#to_unsafe` method or be a `Pointer`.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    #
    # NOTE: Any length *data* might have is ignored.
    # Be sure that *count* is less than or equal to the byte-size length of *data*.
    def []=(range : Range, data)
      size = self.size
      start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      gl_call named_buffer_sub_data(name, start, count, data)
    end

    # Copies a subset of data from one buffer to another.
    def self.copy(from read_buffer, to write_buffer, read_offset : Int, write_offset : Int, size : Int)
      gl_call copy_named_buffer_sub_data(read_buffer, write_buffer, read_offset, write_offset, size)
    end

    # Copies a subset of this buffer into another.
    def copy_to(buffer, read_offset : Int, write_offset : Int, size : Int)
      self.class.copy(self, buffer, read_offset, write_offset, size)
    end

    # Copies a subset of another buffer into this one.
    def copy_from(buffer, read_offset : Int, write_offset : Int, size : Int)
      self.class.copy(buffer, self, read_offset, write_offset, size)
    end

    # Invalidates the entire content of the buffer.
    def invalidate
      gl_call invalidate_buffer_data(name)
    end

    # Invalidates a subset of the buffer's content.
    def invalidate(start : Int, count : Int)
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      gl_call invalidate_buffer_sub_data(name, start, count)
    end

    # Invalidates a subset of the buffer's content.
    def invalidate(range : Range)
      size = self.size
      start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      gl_call invalidate_buffer_sub_data(name, start, count)
    end

    # Maps the buffer's memory into client space.
    def map(access : Access) : Bytes
      pointer = gl_call map_named_buffer(name, access)
      Bytes.new(pointer.as(UInt8*), size, read_only: access.read_only?)
    end

    # Maps a subset of the buffer's memory into client space.
    def map(access : AccessMask, start : Int, count : Int) : Bytes
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      pointer = gl_call.map_named_buffer_range(name, start, count, access)
      Bytes.new(pointer.as(UInt8*), count, read_only: access.read_only?)
    end

    # Maps a subset of the buffer's memory into client space.
    def map(access : AccessMask, range : Range) : Bytes
      size = self.size
      start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      pointer = gl_call map_named_buffer_range(name, start, count, access)
      Bytes.new(pointer.as(UInt8*), count, read_only: access.read_only?)
    end

    # Maps the buffer's memory into the client space.
    # The buffer is automatically unmapped when the block completes.
    # Returns false if the buffer memory was corrupted while it was mapped.
    def map(access : Access, & : Bytes -> _) : Bool
      bytes = map(access)
      begin
        yield bytes
      rescue ex
        unmap
        raise ex
      end
      unmap
    end

    # Maps a subset of the buffer's memory into client space.
    # The buffer is automatically unmapped when the block completes.
    # Returns false if the buffer memory was corrupted while it was mapped.
    def map(access : AccessMask, start : Int, count : Int, & : Bytes -> _) : Bool
      bytes = map(access, start, count)
      begin
        yield bytes
      rescue ex
        unmap
        raise ex
      end
      unmap
    end

    # Maps a subset of the buffer's memory into client space.
    # The buffer is automatically unmapped when the block completes.
    # Returns false if the buffer memory was corrupted while it was mapped.
    def map(access : AccessMask, range : Range, & : Bytes -> _) : Bool
      bytes = map(access, range)
      begin
        yield bytes
      rescue ex
        unmap
        raise ex
      end
      unmap
    end

    # Unmaps the buffer's memory from client space.
    # Returns false if the buffer memory was corrupted while it was mapped.
    def unmap : Bool
      value = gl_call unmap_named_buffer(name)
      !value.false?
    end

    # Flushes the entire mapped buffer range to indicate changes have been made.
    def flush
      size = mapping.size
      gl_call flush_mapped_named_buffer_range(name, 0, size)
    end

    # Flushes a subset of the mapped buffer to indicate changes have been made.
    def flush(start : Int, count : Int)
      size = mapping.size
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      gl_call flush_mapped_named_buffer_range(name, start, count)
    end

    # Flushes a subset of the mapped buffer to indicate changes have been made.
    def flush(range : Range)
      size = mapping.size
      start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      gl_call flush_mapped_named_buffer_range(name, start, count)
    end

    # Retrieves information about the buffer's current map.
    # Returns nil if the buffer isn't mapped.
    def mapping? : Map?
      return unless mapped?

      Map.new(name)
    end

    # Retrieves information about the buffer's current map.
    # Raises if the buffer isn't mapped.
    def mapping : Map
      mapping? || raise NilAssertionError.new("Buffer not mapped")
    end
  end
end
