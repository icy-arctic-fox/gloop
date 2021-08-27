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

    # Non-existent buffer to be used as a null object.
    def self.none
      new(0_u32)
    end

    # Checks if this is a null object for a buffer.
    def none?
      @name.zero?
    end

    # Creates a mutable buffer with initial contents.
    # This effectively combines `.create` and `#data`.
    def self.mutable(data, usage : Usage = :static_draw)
      create.tap do |buffer|
        buffer.data(data, usage)
      end
    end

    # Creates an immutable buffer with initial contents.
    # This effectively combines `.create` and `#storage`.
    def self.immutable(data, flags : Storage)
      create.tap do |buffer|
        buffer.storage(data, flags)
      end
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
    def bind(target : Target | BindTarget)
      checked { LibGL.bind_buffer(target, self) }
    end

    # Binds this buffer to the specified target.
    # The previously bound buffer (if any) is restored after the block exits.
    def bind(target : Target)
      target = BindTarget.new(target)
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
      size = slice.bytesize
      checked { LibGL.named_buffer_data(self, size, slice, usage.named_to_unsafe) }
    end

    # Initializes the buffer of a given size with undefined contents.
    def allocate_data(size : Int, usage : Usage = :static_draw)
      checked { LibGL.named_buffer_data(self, size, nil, usage.named_to_unsafe) }
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
        checked { LibGL.get_named_buffer_sub_data(self, 0, bytes.bytesize, bytes) }
      end
    end

    # Stores data in this buffer.
    # This makes the buffer have a fixed size (immutable).
    # The *data* must have a `#to_slice` method.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    def storage(data, flags : Storage)
      slice = data.to_slice
      size = slice.bytesize
      checked { LibGL.named_buffer_storage(self, size, slice, flags) }
    end

    # Initializes the buffer of a given size with undefined contents.
    # This makes the buffer have a fixed size (immutable).
    def allocate_storage(size : Int, flags : Storage)
      checked { LibGL.named_buffer_storage(self, size, nil, flags) }
    end

    # Retrieves a subset of data from the buffer.
    def []?(start : Int, count : Int) : Bytes?
      start, count = Indexable.normalize_start_and_count(start, count, size) { return nil }
      Bytes.new(count).tap do |bytes|
        checked { LibGL.get_named_buffer_sub_data(self, start, count, bytes) }
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
        checked { LibGL.get_named_buffer_sub_data(self, start, count, bytes) }
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
      checked { LibGL.named_buffer_sub_data(self, start, count, data) }
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
      checked { LibGL.named_buffer_sub_data(self, start, count, data) }
    end

    # Copies a subset of data from one buffer to another.
    def self.copy(from read_buffer, to write_buffer, read_offset : Int, write_offset : Int, size : Int)
      checked { LibGL.copy_named_buffer_sub_data(read_buffer, write_buffer, read_offset, write_offset, size) }
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
      checked { LibGL.invalidate_buffer_data(self) }
    end

    # Invalidates a subset of the buffer's content.
    def invalidate(start : Int, count : Int)
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      checked { LibGL.invalidate_buffer_sub_data(self, start, count) }
    end

    # Invalidates a subset of the buffer's content.
    def invalidate(range : Range)
      size = self.size
      start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      checked { LibGL.invalidate_buffer_sub_data(self, start, count) }
    end

    # Maps the buffer's memory into client space.
    def map(access : Access) : Bytes
      pointer = expect_truthy { LibGL.map_named_buffer(self, access) }
      Bytes.new(pointer.as(UInt8*), size, read_only: access.read_only?)
    end

    # Maps a subset of the buffer's memory into client space.
    def map(access : AccessMask, start : Int, count : Int) : Bytes
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      pointer = expect_truthy { LibGL.map_named_buffer_range(self, start, count, access) }
      Bytes.new(pointer.as(UInt8*), count, read_only: access.read_only?)
    end

    # Maps a subset of the buffer's memory into client space.
    def map(access : AccessMask, range : Range) : Bytes
      size = self.size
      start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new
      start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
      pointer = expect_truthy { LibGL.map_named_buffer_range(self, start, count, access) }
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
      value = checked { LibGL.unmap_named_buffer(self) }
      !value.false?
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
