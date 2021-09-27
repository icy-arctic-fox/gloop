require "./object"
require "./buffer/*"

module Gloop
  # GPU-hosted storage for arbitrary data.
  #
  # Most methods in this type used the "named" OpenGL functions.
  # These utilize DSA (Direct State Access).
  # They should be used whenever possible, but require OpenGL 4.5 or higher.
  # If an older version of OpenGL is required, use corresponding methods in `BindTarget` instead.
  #
  # See: https://www.khronos.org/opengl/wiki/Buffer_Object
  struct Buffer < Object
    include Parameters

    # Integer type used for size-related operations.
    # OpenGL functions will use 32-bit or 64-bit integers depending on the system architecture.
    {% if flag?(:x86_64) %}
      alias Size = Int64
    {% else %}
      alias Size = Int32
    {% end %}

    # Indicates whether the buffer is immutable (fixed size).
    #
    # - OpenGL function: `glGetNamedBufferParameteriv`
    # - OpenGL enum: `GL_BUFFER_IMMUTABLE_STORAGE`
    # - OpenGL version: 4.5
    @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_IMMUTABLE_STORAGE", version: "4.5")]
    buffer_parameter? BufferImmutableStorage, immutable

    # Indicates whether the buffer is currently mapped.
    #
    # - OpenGL function: `glGetNamedBufferParameteriv`
    # - OpenGL enum: `GL_BUFFER_MAPPED`
    # - OpenGL version: 4.5
    @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_MAPPED", version: "4.5")]
    buffer_parameter? BufferMapped, mapped

    # Size of the buffer's contents in bytes.
    #
    # - OpenGL function: `glGetNamedBufferParameteriv`
    # - OpenGL enum: `GL_BUFFER_SIZE`
    # - OpenGL version: 4.5
    @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_SIZE", version: "4.5")]
    buffer_parameter BufferSize, size : Size

    # Retrieves the flags previously set for the buffer's immutable storage.
    #
    # See: `#storage`
    #
    # - OpenGL function: `glGetNamedBufferParameteriv`
    # - OpenGL enum: `GL_BUFFER_STORAGE_FLAGS`
    # - OpenGL version: 4.5
    @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_STORAGE_FLAGS", version: "4.5")]
    buffer_parameter BufferStorageFlags, storage_flags : Storage

    # Retrieves the usage hints previously provided for the buffer's data.
    #
    # See: `#data`
    #
    # - OpenGL function: `glGetNamedBufferParameteriv`
    # - OpenGL enum: `GL_BUFFER_USAGE`
    # - OpenGL version: 4.5
    @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_USAGE", version: "4.5")]
    buffer_parameter BufferUsage, usage : Usage

    # Creates a new buffer.
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    #
    # - OpenGL function: `glCreateBuffers`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateBuffers", version: "4.5")]
    def self.create(context)
      name = uninitialized UInt32
      context.gl.create_buffers(1, pointerof(name))
      new(context, name)
    end

    # Creates multiple new buffers.
    # The number of buffers to create is given by *count*.
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    #
    # - OpenGL function: `glCreateBuffers`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateBuffers", version: "4.5")]
    def self.create(context, count)
      names = Slice(UInt32).new(count)
      context.gl.create_buffers(count, names.to_unsafe)
      names.map { |name| new(context, name) }
    end

    # Generates a new buffer.
    # This ensures a unique name for a buffer object.
    # Resources are not allocated for the buffer until it is bound.
    #
    # See: `.create`
    #
    # - OpenGL function: `glGenBuffers`
    # - OpenGL version: 2.0
    @[GLFunction("glGenBuffers", version: "2.0")]
    def self.generate(context)
      name = uninitialized UInt32
      context.gl.gen_buffers(1, pointerof(name))
      new(context, name)
    end

    # Generates multiple new buffers.
    # This ensures unique names for the buffer objects.
    # Resources are not allocated for the buffers until they are bound.
    #
    # See: `.create`
    #
    # - OpenGL function: `glGenBuffers`
    # - OpenGL version: 2.0
    @[GLFunction("glGenBuffers", version: "2.0")]
    def self.generate(context, count)
      names = Slice(UInt32).new(count)
      context.gl.gen_buffers(count, names.to_unsafe)
      names.map { |name| new(context, name) }
    end

    # Deletes this buffer.
    #
    # - OpenGL function: `glDeleteBuffers`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteBuffers", version: "2.0")]
    def delete
      gl.delete_buffers(1, pointerof(@name))
    end

    # Deletes multiple buffers.
    #
    # - OpenGL function: `glDeleteBuffers`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteBuffers", version: "2.0")]
    def self.delete(buffers : Enumerable(self))
      buffers.group_by(&.context).each do |context, subset|
        names = subset.map(&.to_unsafe)
        context.gl.delete_buffers(buffers.size, names.to_unsafe)
      end
    end

    # Checks if the buffer is known by OpenGL.
    #
    # - OpenGL function: `glIsBuffer`
    # - OpenGL version: 2.0
    @[GLFunction("glIsBuffer", version: "2.0")]
    def exists?
      value = gl.is_buffer(name)
      !value.false?
    end

    # Indicates that this is a buffer object.
    def object_type
      Object::Type::Buffer
    end

    # Binds this buffer to the specified target.
    #
    # - OpenGL function: `glBindBuffer`
    # - OpenGL version: 2.0
    @[GLFunction("glBindBuffer", version: "2.0")]
    def bind(target : Target | BindTarget)
      gl.bind_buffer(target.to_unsafe, to_unsafe)
    end

    # Binds this buffer to the specified target.
    # The previously bound buffer (if any) is restored after the block completes.
    #
    # - OpenGL function: `glBindBuffer`
    # - OpenGL version: 2.0
    @[GLFunction("glBindBuffer", version: "2.0")]
    def bind(target : Target)
      target = BindTarget.new(context, target)
      bind(target) { yield }
    end

    # Binds this buffer to the specified target.
    # The previously bound buffer (if any) is restored after the block completes.
    #
    # - OpenGL function: `glBindBuffer`
    # - OpenGL version: 2.0
    @[GLFunction("glBindBuffer", version: "2.0")]
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
    #
    # - OpenGL function: `glNamedBufferData`
    # - OpenGL version: 4.5
    @[GLFunction("glNamedBufferData", version: "4.5")]
    def data(data, usage : Usage = :static_draw)
      slice = data.to_slice
      pointer = slice.to_unsafe.as(Void*)
      size = Size.new(slice.bytesize)
      gl.named_buffer_data(to_unsafe, size, pointer, usage.named_to_unsafe)
    end

    # Initializes the buffer of a given size with undefined contents.
    #
    # - OpenGL function: `glNamedBufferData`
    # - OpenGL version: 4.5
    @[GLFunction("glNamedBufferData", version: "4.5")]
    def allocate_data(size : Size, usage : Usage = :static_draw)
      gl.named_buffer_data(to_unsafe, size, Pointer(Void).null, usage.named_to_unsafe)
    end

    # Stores data in this buffer.
    # The *data* must have a `#to_slice` method.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    # Previously set `#usage` hint is reapplied for this data.
    #
    # - OpenGL function: `glNamedBufferData`
    # - OpenGL version: 4.5
    @[GLFunction("glNamedBufferData", version: "4.5")]
    def data=(data)
      self.data(data, usage)
    end

    # Retrieves all data in the buffer.
    #
    # NOTE: Modifying the data returned by this method *will not* update the contents of the buffer.
    #
    # - OpenGL function: `glGetNamedBufferSubData`
    # - OpenGL version: 4.5
    @[GLFunction("glGetNamedBufferSubData", version: "4.5")]
    def data
      Bytes.new(size).tap do |bytes|
        start = Size.new(0)
        size = Size.new(bytes.bytesize)
        pointer = bytes.to_unsafe.as(Void*)
        gl.get_named_buffer_sub_data(to_unsafe, start, size, pointer.as(Void*))
      end
    end

    # Stores data in this buffer.
    # This makes the buffer have a fixed size (immutable).
    # The *data* must have a `#to_slice` method.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    #
    # - OpenGL function: `glNamedBufferData`
    # - OpenGL version: 4.5
    @[GLFunction("glNamedBufferStorage", version: "4.5")]
    def storage(data, flags : Storage)
      slice = data.to_slice
      pointer = slice.to_unsafe.as(Void*)
      size = Size.new(slice.bytesize)
      gl.named_buffer_storage(to_unsafe, size, pointer, flags.to_unsafe)
    end

    # Initializes the buffer of a given size with undefined contents.
    # This makes the buffer have a fixed size (immutable).
    #
    # - OpenGL function: `glNamedBufferData`
    # - OpenGL version: 4.5
    @[GLFunction("glNamedBufferStorage", version: "4.5")]
    def allocate_storage(size : Size, flags : Storage)
      gl.named_buffer_storage(to_unsafe, size, Pointer(Void).null, flags.to_unsafe)
    end

    # Retrieves a subset of data from the buffer.
    #
    # - OpenGL function: `glGetNamedBufferSubData`
    # - OpenGL version: 4.5
    @[GLFunction("glGetNamedBufferSubData", version: "4.5")]
    def [](start : Size, count : Size) : Bytes?
      Bytes.new(count).tap do |bytes|
        gl.get_named_buffer_sub_data(to_unsafe, start, count, bytes.to_unsafe.as(Void*))
      end
    end

    # Retrieves a range of data from the buffer.
    #
    # - OpenGL function: `glGetNamedBufferSubData`
    # - OpenGL version: 4.5
    @[GLFunction("glGetNamedBufferSubData", version: "4.5")]
    @[AlwaysInline]
    def [](range : Range) : Bytes?
      start = Size.new(range.begin)
      count = Size.new(range.size)
      self[start, count]
    end

    # Updates a subset of the buffer's data store.
    #
    # The number of bytes updated in the buffer is equal to the byte size of *data*.
    # The *data* must have a `#to_slice`.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    #
    # - OpenGL function: `glNamedBufferSubData`
    # - OpenGL version: 4.5
    @[GLFunction("glNamedBufferSubData", version: "4.5")]
    def update(offset : Size, data)
      slice = data.to_slice
      count = Size.new(slice.bytesize)
      self[offset, count] = slice
    end

    # Updates a subset of the buffer's data store.
    #
    # The *data* must have a `#to_unsafe` method or be a `Pointer`.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    #
    # NOTE: Any length *data* might have is ignored.
    # Be sure that *count* is less than or equal to the byte size length of *data*.
    #
    # - OpenGL function: `glNamedBufferSubData`
    # - OpenGL version: 4.5
    @[GLFunction("glNamedBufferSubData", version: "4.5")]
    def []=(start : Size, count : Size, data)
      pointer = if data.responds_to?(:to_unsafe)
                  data.to_unsafe
                else
                  data
                end

      gl.named_buffer_sub_data(to_unsafe, start, count, pointer.as(Void*))
    end

    # Updates a subset of the buffer's data store.
    #
    # The *data* must have a `#to_unsafe` method or be a `Pointer`.
    # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
    #
    # NOTE: Any length *data* might have is ignored.
    # Be sure that *count* is less than or equal to the byte-size length of *data*.
    #
    # - OpenGL function: `glNamedBufferSubData`
    # - OpenGL version: 4.5
    @[GLFunction("glNamedBufferSubData", version: "4.5")]
    @[AlwaysInline]
    def []=(range : Range, data)
      start = Size.new(range.begin)
      count = Size.new(range.size)
      self[start, count] = data
    end

    # Copies a subset of data from one buffer to another.
    #
    # The *read_offset* indicates the byte offset to start copying from *read_buffer*.
    # The *write_offset* indicates the byte offset to start copying into *write_buffer*.
    # The *size* is the number of bytes to copy.
    #
    # - OpenGL function: `glCopyNamedBufferSubData`
    # - OpenGL version: 4.5
    @[GLFunction("glCopyNamedBufferSubData", version: "4.5")]
    def self.copy(from read_buffer : self, to write_buffer : self,
                  read_offset : Size, write_offset : Size, size : Size)
      {% if !flag?(:release) || flag?(:error_checking) %}
        raise "Attempt to copy buffers from different contexts" if read_buffer.context != write_buffer.context
      {% end %}

      context = read_buffer.context
      context.gl.copy_named_buffer_sub_data(
        read_buffer.to_unsafe, write_buffer.to_unsafe, read_offset, write_offset, size)
    end

    # Copies a subset of this buffer into another.
    #
    # The *read_offset* indicates the byte offset to start copying from this buffer.
    # The *write_offset* indicates the byte offset to start copying into *write_buffer*.
    # The *size* is the number of bytes to copy.
    #
    # - OpenGL function: `glCopyNamedBufferSubData`
    # - OpenGL version: 4.5
    @[GLFunction("glCopyNamedBufferSubData", version: "4.5")]
    @[AlwaysInline]
    def copy_to(buffer : self, read_offset : Size, write_offset : Size, size : Size)
      self.class.copy(self, buffer, read_offset, write_offset, size)
    end

    # Copies a subset of another buffer into this one.
    #
    # The *read_offset* indicates the byte offset to start copying from *read_buffer*.
    # The *write_offset* indicates the byte offset to start copying into this buffer.
    # The *size* is the number of bytes to copy.
    #
    # - OpenGL function: `glCopyNamedBufferSubData`
    # - OpenGL version: 4.5
    @[GLFunction("glCopyNamedBufferSubData", version: "4.5")]
    @[AlwaysInline]
    def copy_from(buffer : self, read_offset : Size, write_offset : Size, size : Size)
      self.class.copy(buffer, self, read_offset, write_offset, size)
    end

    # Invalidates the entire content of the buffer.
    #
    # - OpenGL function: `glInvalidateBufferData`
    # - OpenGL version: 4.3
    @[GLFunction("glInvalidateBufferData", version: "4.3")]
    def invalidate
      gl.invalidate_buffer_data(to_unsafe)
    end

    # Invalidates a subset of the buffer's content.
    #
    # - OpenGL function: `glInvalidateBufferSubData`
    # - OpenGL version: 4.3
    @[GLFunction("glInvalidateBufferSubData", version: "4.3")]
    def invalidate(start : Size, count : Size)
      gl.invalidate_buffer_sub_data(to_unsafe, start, count)
    end

    # Invalidates a subset of the buffer's content.
    #
    # - OpenGL function: `glInvalidateBufferSubData`
    # - OpenGL version: 4.3
    @[GLFunction("glInvalidateBufferSubData", version: "4.3")]
    @[AlwaysInline]
    def invalidate(range : Range)
      start = Size.new(range.begin)
      count = Size.new(range.size)
      invalidate(start, count)
    end

    # Maps the buffer's memory into client space.
    #
    # - OpenGL function: `glMapNamedBuffer`
    # - OpenGL version: 4.5
    @[GLFunction("glMapNamedBuffer", version: "4.5")]
    def map(access : Access) : Bytes
      pointer = gl.map_named_buffer(to_unsafe, access.to_unsafe)
      Bytes.new(pointer.as(UInt8*), size, read_only: access.read_only?)
    end

    # Maps a subset of the buffer's memory into client space.
    #
    # - OpenGL function: `glMapNamedBufferRange`
    # - OpenGL version: 4.5
    @[GLFunction("glMapNamedBufferRange", version: "4.5")]
    def map(access : AccessMask, start : Size, count : Size) : Bytes
      pointer = gl.map_named_buffer_range(to_unsafe, start, count, access.to_unsafe)
      Bytes.new(pointer.as(UInt8*), count, read_only: access.read_only?)
    end

    # Maps a subset of the buffer's memory into client space.
    #
    # - OpenGL function: `glMapNamedBufferRange`
    # - OpenGL version: 4.5
    @[GLFunction("glMapNamedBufferRange", version: "4.5")]
    @[AlwaysInline]
    def map(access : AccessMask, range : Range) : Bytes
      start = Size.new(range.begin)
      count = Size.new(range.size)
      map(access, start, count)
    end

    # Maps the buffer's memory into the client space.
    #
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
    #
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
    #
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
    #
    # - OpenGL function: `glUnmapNamedBuffer`
    # - OpenGL version: 4.5
    @[GLFunction("glUnmapNamedBuffer", version: "4.5")]
    def unmap : Bool
      value = gl.unmap_named_buffer(to_unsafe)
      !value.false?
    end

    # Flushes the entire mapped buffer range to indicate changes have been made.
    #
    # - OpenGL function: `glFlushMappedNamedBufferRange`
    # - OpenGL version: 4.5
    @[GLFunction("glFlushMappedNamedBufferRange", version: "4.5")]
    @[AlwaysInline]
    def flush
      flush(0, mapping.size)
    end

    # Flushes a subset of the mapped buffer to indicate changes have been made.
    #
    # - OpenGL function: `glFlushMappedNamedBufferRange`
    # - OpenGL version: 4.5
    @[GLFunction("glFlushMappedNamedBufferRange", version: "4.5")]
    def flush(start : Size, count : Size)
      gl.flush_mapped_named_buffer_range(to_unsafe, start, count)
    end

    # Flushes a subset of the mapped buffer to indicate changes have been made.
    #
    # - OpenGL function: `glFlushMappedNamedBufferRange`
    # - OpenGL version: 4.5
    @[GLFunction("glFlushMappedNamedBufferRange", version: "4.5")]
    @[AlwaysInline]
    def flush(range : Range)
      start = Size.new(range.begin)
      count = Size.new(range.size)
      flush(start, count)
    end

    # Retrieves information about the buffer's current map.
    # Returns nil if the buffer isn't mapped.
    def mapping? : Map?
      return unless mapped?

      Map.new(context, name)
    end

    # Retrieves information about the buffer's current map.
    # Raises if the buffer isn't mapped.
    def mapping : Map
      mapping? || raise NilAssertionError.new("Buffer not mapped")
    end
  end

  struct Context
    # Creates a buffer in this context.
    # See: `Buffer.create`
    def create_buffer
      Buffer.create(self)
    end

    # Creates multiple buffers in this context.
    # See: `Buffer.create`
    def create_buffers(count : Int)
      Buffer.create(self, count)
    end

    # Generates a buffer in this context.
    # See: `Buffer.generate`
    def generate_buffer
      Buffer.generate(self)
    end

    # Generates multiple buffer in this context.
    # See: `Buffer.generate`
    def generate_buffers(count : Int)
      Buffer.generate(self, count)
    end
  end
end
