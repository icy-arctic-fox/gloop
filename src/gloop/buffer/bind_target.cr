require "../error_handling"
require "../gl_functions"
require "./buffer_target_parameters"
require "./target"

module Gloop
  struct Buffer < Object
    # Reference to a target that a buffer can be bound to.
    # Provides operations for working with buffers bound to the target.
    struct BindTarget
      extend ErrorHandling
      include BufferTargetParameters
      include ErrorHandling
      include GLFunctions

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

      # Retrieves the context for this target.
      getter context

      # Target this binding refers to.
      getter target : Target

      protected def initialize(@context : Context, @target : Target)
      end

      # Retrieves the buffer currently bound to this target.
      # If there is no buffer bound, nil is returned.
      def buffer? : Buffer?
        pname = binding_pname
        name = uninitialized Int32
        gl_call get_integer_v(pname, pointerof(name))
        Buffer.new(@context, name.to_u32!) unless name.zero?
      end

      # Retrieves the buffer currently bound to this target.
      # If there is no buffer bound, `Buffer.none` is returned.
      def buffer : Buffer
        pname = binding_pname
        name = uninitialized Int32
        gl_call get_integer_v(pname, pointerof(name))
        Buffer.new(@context, name.to_u32!)
      end

      # Retrieves the corresponding parameter value for `glGet` for this target.
      private def binding_pname # ameba:disable Metrics/CyclomaticComplexity
        case @target
        in Target::Array             then LibGL::GetPName::ArrayBufferBinding
        in Target::ElementArray      then LibGL::GetPName::ElementArrayBufferBinding
        in Target::PixelPack         then LibGL::GetPName::PixelPackBufferBinding
        in Target::PixelUnpack       then LibGL::GetPName::PixelUnpackBufferBinding
        in Target::TransformFeedback then LibGL::GetPName::TransformFeedbackBufferBinding
        in Target::Texture           then LibGL::GetPName.new(LibGL::TEXTURE_BUFFER_BINDING.to_u32!)
        in Target::CopyRead          then LibGL::GetPName.new(LibGL::COPY_READ_BUFFER_BINDING.to_u32!)
        in Target::CopyWrite         then LibGL::GetPName.new(LibGL::COPY_WRITE_BUFFER_BINDING.to_u32!)
        in Target::Uniform           then LibGL::GetPName::UniformBufferBinding
        in Target::DrawIndirect      then LibGL::GetPName.new(LibGL::DRAW_INDIRECT_BUFFER_BINDING.to_u32!)
        in Target::AtomicCounter     then LibGL::GetPName.new(LibGL::AtomicCounterBufferPName::AtomicCounterBufferBinding.to_u32!)
        in Target::DispatchIndirect  then LibGL::GetPName::DispatchIndirectBufferBinding
        in Target::ShaderStorage     then LibGL::GetPName::ShaderStorageBufferBinding
        in Target::Query             then LibGL::GetPName.new(LibGL::QUERY_BUFFER_BINDING.to_u32!)
        in Target::Parameter         then LibGL::GetPName.new(LibGL::PARAMETER_BUFFER_BINDING.to_u32!)
        end
      end

      # Binds a buffer to this target.
      def bind(buffer)
        gl_call bind_buffer(target, buffer)
      end

      # Binds a buffer to this target.
      # The previously bound buffer (if any) is restored after the block exits.
      def bind(buffer)
        previous = self.buffer
        bind(buffer)

        begin
          yield
        ensure
          bind(previous)
        end
      end

      # Unbinds any previously bound buffer from this target.
      def unbind
        gl_call bind_buffer(target, 0)
      end

      # Stores data in the buffer currently bound to this target.
      # The *data* must have a `#to_slice` method.
      # The `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      def data(data, usage : Usage = :static_draw)
        slice = data.to_slice
        size = slice.bytesize
        gl_call buffer_data(target, size, slice, usage)
      end

      # Initializes the currently bound buffer to a given size with undefined contents.
      def allocate_data(size : Int, usage : Usage = :static_draw)
        gl_call buffer_data(target, size, nil, usage)
      end

      # Stores data in the buffer currently bound to this target.
      # The *data* must have a `#to_slice` method.
      # The `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      # Previously set `#usage` hint is reapplied for this data.
      def data=(data)
        self.data(data, usage)
      end

      # Retrieves all data in the buffer currently bound to this target.
      def data
        Bytes.new(size).tap do |bytes|
          gl_call get_buffer_sub_data(target, 0, bytes.bytesize, bytes)
        end
      end

      # Stores data in the buffer currently bound to this target.
      # This makes the buffer have a fixed size (immutable).
      # The *data* must have a `#to_slice` method.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      def storage(data, flags : Storage)
        slice = data.to_slice
        size = slice.bytesize
        gl_call buffer_storage(storage_target, size, slice, flags)
      end

      # Initializes the currently bound buffer to a given size with undefined contents.
      # This makes the buffer have a fixed size (immutable).
      def allocate_storage(size : Int, flags : Storage)
        gl_call buffer_storage(storage_target, size, nil, flags)
      end

      # Retrieves a subset of data from the buffer currently bound to this target.
      def []?(start : Int, count : Int) : Bytes?
        start, count = Indexable.normalize_start_and_count(start, count, size) { return nil }
        Bytes.new(count).tap do |bytes|
          gl_call get_buffer_sub_data(target, start, count, bytes)
        end
      end

      # Retrieves a subset of data from the buffer currently bound to this target.
      def [](start : Int, count : Int) : Bytes
        self[start, count]? || raise IndexError.new
      end

      # Retrieves a range of data from the buffer currently bound to this target.
      def []?(range : Range) : Bytes?
        size = self.size
        start, count = Indexable.range_to_index_and_count(range, size) || return nil
        start, count = Indexable.normalize_start_and_count(start, count, size) { return nil }
        Bytes.new(count).tap do |bytes|
          gl_call get_buffer_sub_data(target, start, count, bytes)
        end
      end

      # Retrieves a range of data from the buffer currently bound to this target
      def [](range : Range) : Bytes
        self[range]? || raise IndexError.new
      end

      # Updates a subset of the currently bound buffer's data store.
      # The number of bytes updated in the buffer is equal to the byte-size of *data*.
      # The *data* must have a `#to_slice`.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      def update(offset : Int, data)
        slice = data.to_slice
        self[offset, slice.bytesize] = slice
      end

      # Updates a subset of the currently bound buffer's data store.
      # The *data* must have a `#to_unsafe` method or be a `Pointer`.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      #
      # NOTE: Any length *data* might have is ignored.
      # Be sure that *count* is less than or equal to the byte-size length of *data*.
      def []=(start : Int, count : Int, data)
        start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
        gl_call buffer_sub_data(target, start, count, data)
      end

      # Updates a subset of the currently bound buffer's data store.
      # The *data* must have a `#to_unsafe` method or be a `Pointer`.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      #
      # NOTE: Any length *data* might have is ignored.
      # Be sure that *count* is less than or equal to the byte-size length of *data*.
      def []=(range : Range, data)
        size = self.size
        start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new
        start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
        gl_call buffer_sub_data(target, start, count, data)
      end

      # Copies a subset of data from a buffer bound to one target into one bound by another target.
      def self.copy(from read_target : Target | self, to write_target : Target | self,
                    read_offset : Int, write_offset : Int, size : Int)
        checked do
          gl_call copy_buffer_sub_data(
            read_target.copy_buffer_target, write_target.copy_buffer_target,
            read_offset, write_offset, size)
        end
      end

      # Copies a subset of the buffer bound to this target into another.
      def copy_to(target : Target | self, read_offset : Int, write_offset : Int, size : Int)
        self.class.copy(self, target, read_offset, write_offset, size)
      end

      # Copies a subset of another buffer into the buffer bound to this target.
      def copy_from(target : Target | self, read_offset : Int, write_offset : Int, size : Int)
        self.class.copy(target, self, read_offset, write_offset, size)
      end

      # Maps the buffer's memory into client space.
      def map(access : Access) : Bytes
        pointer = gl_call map_buffer(target, access)
        Bytes.new(pointer.as(UInt8*), size, read_only: access.read_only?)
      end

      # Maps a subset of the buffer's memory into client space.
      def map(access : AccessMask, start : Int, count : Int) : Bytes
        start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
        pointer = gl_call map_buffer_range(target, start, count, access)
        Bytes.new(pointer.as(UInt8*), count, read_only: access.read_only?)
      end

      # Maps a subset of the buffer's memory into client space.
      def map(access : AccessMask, range : Range) : Bytes
        size = self.size
        start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new
        start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
        pointer = gl_call map_buffer_range(target, start, count, access)
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
        value = gl_call unmap_buffer(target)
        !value.false?
      end

      # Flushes the entire mapped buffer range to indicate changes have been made.
      def flush
        size = mapping.size
        gl_call flush_mapped_buffer_range(target, 0, size)
      end

      # Flushes a subset of the mapped buffer to indicate changes have been made.
      def flush(start : Int, count : Int)
        size = mapping.size
        start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
        gl_call flush_mapped_buffer_range(target, start, count)
      end

      # Flushes a subset of the mapped buffer to indicate changes have been made.
      def flush(range : Range)
        size = mapping.size
        start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new
        start, count = Indexable.normalize_start_and_count(start, count, size) { raise IndexError.new }
        gl_call flush_mapped_buffer_range(target, start, count)
      end

      # Retrieves information about the bound buffer's current map.
      # Returns nil if the buffer isn't mapped.
      def mapping? : TargetMap?
        return unless mapped?

        TargetMap.new(target)
      end

      # Retrieves information about the bound buffer's current map.
      # Raises if the buffer isn't mapped.
      def mapping : TargetMap
        mapping? || raise NilAssertionError.new("Buffer not mapped")
      end

      # Returns an OpenGL enum representing this buffer binding target.
      def to_unsafe
        @target.to_unsafe
      end

      # Returns an OpenGL enum representing this buffer binding target.
      # This intended to be used with `glBufferStorage` since it uses a different enum group.
      private def storage_target
        LibGL::BufferStorageTarget.new(@target.value)
      end

      # Returns an OpenGL enum representing this buffer binding target.
      # This intended to be used with `glCopyBufferSubData` since it uses a different enum group.
      protected def copy_buffer_target
        LibGL::CopyBufferSubDataTarget.new(@target.value)
      end
    end
  end
end
