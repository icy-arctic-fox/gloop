require "../contextual"
require "../size"
require "./parameters"
require "./storage"
require "./target"
require "./usage"

module Gloop
  struct Buffer < Object
    # Reference to a target that a buffer can be bound to.
    # Provides operations for working with buffers bound to the target.
    struct BindTarget
      include Contextual
      include Parameters

      # Indicates whether the buffer is immutable.
      #
      # See: `Buffer#immutable?`
      #
      # - OpenGL function: `glGetBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_IMMUTABLE_STORAGE`
      # - OpenGL version: 4.5
      @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_IMMUTABLE_STORAGE", version: "4.5")]
      buffer_target_parameter? BufferImmutableStorage, immutable

      # Indicates whether the buffer is currently mapped.
      #
      # See: `Buffer#mapped?`
      #
      # - OpenGL function: `glGetBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_MAPPED`
      # - OpenGL version: 4.5
      @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_MAPPED", version: "4.5")]
      buffer_target_parameter? BufferMapped, mapped

      # Size of the buffer's contents in bytes.
      #
      # See: `Buffer#size`
      #
      # - OpenGL function: `glGetBufferParameteriv`, `glGetBufferParameteri64v`
      # - OpenGL enum: `GL_BUFFER_SIZE`
      # - OpenGL version: 2.0, 3.2
      {% if flag?(:x86_64) %}
        @[GLFunction("glGetBufferParameteri64v", enum: "GL_BUFFER_SIZE", version: "4.5")]
      {% else %}
        @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_SIZE", version: "4.5")]
      {% end %}
      buffer_target_parameter BufferSize, size

      # Retrieves the flags previously set for the buffer's immutable storage.
      #
      # See: `#storage`
      #
      # See: `Buffer#storage_flags`
      #
      # - OpenGL function: `glGetBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_STORAGE_FLAGS`
      # - OpenGL version: 4.4
      @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_STORAGE_FLAGS", version: "4.5")]
      buffer_target_parameter BufferStorageFlags, storage_flags : Storage

      # Retrieves the usage hints previously provided for the buffer's data.
      #
      # See: `#data`
      #
      # See: `Buffer#usage`
      #
      # - OpenGL function: `glGetBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_USAGE`
      # - OpenGL version: 2.0
      @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_USAGE", version: "4.5")]
      buffer_target_parameter BufferUsage, usage : Usage

      # Retrieves the context for this target.
      getter context

      # Target this binding refers to.
      getter target : Target

      # Creates a reference to a buffer bind target.
      protected def initialize(@context : Context, @target : Target)
      end

      # Retrieves the name of the buffer currently bound to this target.
      #
      # Returns a null-object (zero) if no buffer is bound.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL version: 2.0
      @[GLFunction("glGetIntegerv", version: "2.0")]
      private def buffer_name : Name
        value = uninitialized Int32
        gl.get_integer_v(binding_pname, pointerof(value))
        Name.new!(value)
      end

      # Retrieves the buffer currently bound to this target.
      #
      # Returns nil if no buffer is bound.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL version: 2.0
      @[GLFunction("glGetIntegerv", version: "2.0")]
      def buffer? : Buffer?
        name = buffer_name
        Buffer.new(@context, name) unless name.zero?
      end

      # Retrieves the buffer currently bound to this target.
      #
      # Returns `.none` if no buffer is bound.
      #
      # - OpenGL function: `glGetIntegerv`
      # - OpenGL version: 2.0
      @[GLFunction("glGetIntegerv", version: "2.0")]
      def buffer : Buffer
        Buffer.new(@context, buffer_name)
      end

      # Binds a buffer to this target.
      #
      # See: `Buffer#bind`
      #
      # - OpenGL function: `glBindBuffer`
      # - OpenGL version: 2.0
      @[GLFunction("glBindBuffer", version: "2.0")]
      def bind(buffer : Buffer)
        gl.bind_buffer(to_unsafe, buffer.to_unsafe)
      end

      # Binds a buffer to this target.
      #
      # The previously bound buffer (if any) is restored after the block completes.
      #
      # See: `Buffer#bind`
      #
      # - OpenGL function: `glBindBuffer`
      # - OpenGL version: 2.0
      @[GLFunction("glBindBuffer", version: "2.0")]
      def bind(buffer : Buffer)
        previous = self.buffer
        bind(buffer)

        begin
          yield
        ensure
          bind(previous)
        end
      end

      # Unbinds any previously bound buffer from this target.
      #
      # - OpenGL function: `glBindBuffer`
      # - OpenGL version: 2.0
      @[GLFunction("glBindBuffer", version: "2.0")]
      def unbind
        gl.bind_buffer(to_unsafe, 0_u32)
      end

      # Stores data in the buffer currently bound to this target.
      #
      # The *data* must have a `#to_slice` method.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      #
      # See: `Buffer#data`
      #
      # - OpenGL function: `glBufferData`
      # - OpenGL version: 2.0
      @[GLFunction("glBufferData", version: "2..0")]
      def data(data, usage : Usage = :static_draw)
        slice = data.to_slice
        pointer = slice.to_unsafe.as(Void*)
        size = Size.new(slice.bytesize)
        gl.buffer_data(to_unsafe, size, pointer, usage.to_unsafe)
      end

      # Initializes the currently bound buffer to a given size with undefined contents.
      #
      # See: `Buffer#allocate_data`
      #
      # - OpenGL function: `glBufferData`
      # - OpenGL version: 2.0
      @[GLFunction("glBufferData", version: "2.0")]
      def allocate_data(size : Size, usage : Usage = :static_draw)
        gl.buffer_data(to_unsafe, size, Pointer(Void).null, usage.to_unsafe)
      end

      # Stores data in the buffer currently bound to this target.
      #
      # The *data* must have a `#to_slice` method.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      # Previously set `#usage` hint is reapplied for this data.
      #
      # See: `Buffer#data=`
      #
      # - OpenGL function: `glBufferData`
      # - OpenGL version: 2.0
      @[GLFunction("glBufferData", version: "2.0")]
      @[AlwaysInline]
      def data=(data)
        self.data(data, usage)
      end

      # Retrieves all data in the buffer currently bound to this target.
      #
      # NOTE: Modifying the data returned by this method *will not* update the contents of the buffer.
      #
      # See: `Buffer#data`
      #
      # - OpenGL function: `glGetBufferSubData`
      # - OpenGL version: 2.0
      @[GLFunction("glGetBufferSubData", version: "2.0")]
      def data
        Bytes.new(size).tap do |bytes|
          start = Size.new!(0)
          size = Size.new(bytes.bytesize)
          pointer = bytes.to_unsafe.as(Void*)
          gl.get_buffer_sub_data(to_unsafe, start, size, pointer)
        end
      end

      # Stores data in the buffer currently bound to this target.
      # This makes the buffer have a fixed size (immutable).
      #
      # The *data* must have a `#to_slice` method.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      #
      # See: `Buffer#storage`
      #
      # - OpenGL function: `glBufferStorage`
      # - OpenGL version: 4.4
      @[GLFunction("glBufferStorage", version: "4.4")]
      def storage(data, flags : Storage)
        slice = data.to_slice
        pointer = slice.to_unsafe.as(Void*)
        size = Size.new(slice.bytesize)
        gl.buffer_storage(storage_target, size, pointer, flags.to_unsafe)
      end

      # Initializes the currently bound buffer to a given size with undefined contents.
      # This makes the buffer have a fixed size (immutable).
      #
      # See: `Buffer#allocate_storage`
      #
      # - OpenGL function: `glBufferStorage`
      # - OpenGL version: 4.4
      @[GLFunction("glBufferStorage", version: "4.4")]
      def allocate_storage(size : Size, flags : Storage)
        gl.buffer_storage(storage_target, size, Pointer(Void).null, flags.to_unsafe)
      end

      # Retrieves a subset of data from the buffer currently bound to this target.
      #
      # NOTE: Modifying the data returned by this method *will not* update the contents of the buffer.
      #
      # See: `Buffer#[]`
      #
      # - OpenGL function: `glGetBufferSubData`
      # - OpenGL version: 2.0
      @[GLFunction("glGetBufferSubData", version: "2.0")]
      def [](start : Size, count : Size) : Bytes
        Bytes.new(count).tap do |bytes|
          gl.get_buffer_sub_data(to_unsafe, start, count, bytes.to_unsafe.as(Void*))
        end
      end

      # Retrieves a range of data from the buffer currently bound to this target.
      #
      # NOTE: Modifying the data returned by this method *will not* update the contents of the buffer.
      #
      # See: `Buffer#[]`
      #
      # - OpenGL function: `glGetBufferSubData`
      # - OpenGL version: 2.0
      @[GLFunction("glGetBufferSubData", version: "2.0")]
      @[AlwaysInline]
      def [](range : Range) : Bytes
        start = Size.new(range.begin)
        count = Size.new(range.size)
        self[start, count]
      end

      # Updates a subset of the currently bound buffer's data store.
      #
      # The number of bytes updated in the buffer is equal to the byte size of *data*.
      # The *data* must have a `#to_slice`.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      #
      # See: `Buffer#update`
      #
      # - OpenGL function: `glBufferSubData`
      # - OpenGL version: 2.0
      @[GLFunction("glBufferSubData", version: "2.0")]
      def update(offset : Size, data) : self
        slice = data.to_slice
        count = Size.new(slice.bytesize)
        self[offset, count] = slice
        self
      end

      # Updates a subset of the currently bound buffer's data store.
      #
      # The *data* must have a `#to_unsafe` method or be a `Pointer`.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      #
      # NOTE: Any length *data* might have is ignored.
      # Be sure that *count* is less than or equal to the byte size length of *data*.
      #
      # See: `Buffer#[]=`
      #
      # - OpenGL function: `glBufferSubData`
      # - OpenGL version: 2.0
      @[GLFunction("glBufferSubData", version: "2.0")]
      def []=(start : Size, count : Size, data)
        pointer = if data.responds_to?(:to_unsafe)
                    data.to_unsafe
                  else
                    data
                  end

        gl.buffer_sub_data(to_unsafe, start, count, pointer.as(Void*))
      end

      # Updates a subset of the currently bound buffer's data store.
      #
      # The *data* must have a `#to_unsafe` method or be a `Pointer`.
      # `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      #
      # NOTE: Any length *data* might have is ignored.
      # Be sure that *count* is less than or equal to the byte-size length of *data*.
      #
      # See: `Buffer#[]=`
      #
      # - OpenGL function: `glBufferSubData`
      # - OpenGL version: 2.0
      @[GLFunction("glBufferSubData", version: "2.0")]
      @[AlwaysInline]
      def []=(range : Range, data)
        start = Size.new(range.begin)
        count = Size.new(range.size)
        self[start, count] = data
      end

      # Copies a subset of data from a buffer bound to one target into one bound by another target.
      #
      # The *read_offset* indicates the byte offset to start copying from *read_target*.
      # The *write_offset* indicates the byte offset to start copying into *write_target*.
      # The *size* is the number of bytes to copy.
      #
      # See: `Buffer.copy`
      #
      # - OpenGL function: `glCopyBufferSubData`
      # - OpenGL version: 3.1
      @[GLFunction("glCopyBufferSubData", version: "3.1")]
      def self.copy(from read_target : Target | self, to write_target : Target | self,
                    read_offset : Size, write_offset : Size, size : Size)
        {% if !flag?(:release) || flag?(:error_checking) %}
          raise "Attempt to copy buffers from different contexts" if read_target.context != write_target.context
        {% end %}

        context = read_target.context
        context.gl.copy_buffer_sub_data(
          read_target.copy_buffer_target, write_target.copy_buffer_target, read_offset, write_offset, size)
      end

      # Copies a subset of the buffer bound to this target into another.
      #
      # The *read_offset* indicates the byte offset to start copying from the buffer bound to this target.
      # The *write_offset* indicates the byte offset to start copying into *target*.
      # The *size* is the number of bytes to copy.
      #
      # See: `Buffer#copy_to`
      #
      # - OpenGL function: `glCopyBufferSubData`
      # - OpenGL version: 3.1
      @[GLFunction("glCopyBufferSubData", version: "3.1")]
      @[AlwaysInline]
      def copy_to(target : Target | self, read_offset : Size, write_offset : Size, size : Size)
        self.class.copy(self, target, read_offset, write_offset, size)
      end

      # Copies a subset of another buffer into the buffer bound to this target.
      #
      # The *read_offset* indicates the byte offset to start copying from *target*.
      # The *write_offset* indicates the byte offset to start copying into the buffer bound to this target..
      # The *size* is the number of bytes to copy.
      #
      # See: `Buffer#copy_from`
      #
      # - OpenGL function: `glCopyBufferSubData`
      # - OpenGL version: 3.1
      @[GLFunction("glCopyBufferSubData", version: "3.1")]
      @[AlwaysInline]
      def copy_from(target : Target | self, read_offset : Size, write_offset : Size, size : Size)
        self.class.copy(target, self, read_offset, write_offset, size)
      end

      # Maps the buffer's memory into client space.
      #
      # See: `Buffer#map`
      #
      # - OpenGL function: `glMapBuffer`
      # - OpenGL version: 2.0
      @[GLFunction("glMapBuffer", version: "2.0")]
      def map(access : Access) : Bytes
        pointer = gl.map_buffer(to_unsafe, access.to_unsafe)
        Bytes.new(pointer.as(UInt8*), size, read_only: access.read_only?)
      end

      # Maps a subset of the buffer's memory into client space.
      #
      # See: `Buffer#map`
      #
      # - OpenGL function: `glMapBufferRange`
      # - OpenGL version: 3.0
      @[GLFunction("glMapBufferRange", version: "3.0")]
      def map(access : AccessMask, start : Size, count : Size) : Bytes
        pointer = gl.map_buffer_range(to_unsafe, start, count, access.to_unsafe)
        Bytes.new(pointer.as(UInt8*), count, read_only: access.read_only?)
      end

      # Maps a subset of the buffer's memory into client space.
      #
      # See: `Buffer#map`
      #
      # - OpenGL function: `glMapBufferRange`
      # - OpenGL version: 3.0
      @[GLFunction("glMapBufferRange", version: "3.0")]
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
      #
      # See: `Buffer#map`
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
      #
      # See: `Buffer#map`
      def map(access : AccessMask, start : Size, count : Size, & : Bytes -> _) : Bool
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
      #
      # See: `Buffer#map`
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
      #
      # Returns false if the buffer memory was corrupted while it was mapped.
      #
      # See: `Buffer#unmap`
      #
      # - OpenGL function: `glUnmapBuffer`
      # - OpenGL version: 2.0
      @[GLFunction("glUnmapBuffer", version: "2.0")]
      def unmap : Bool
        value = gl.unmap_buffer(to_unsafe)
        !value.false?
      end

      # Flushes the entire mapped buffer range to indicate changes have been made.
      #
      # See: `Buffer#flush`
      #
      # - OpenGL function: `glFlushMappedBufferRange`
      # - OpenGL version: 3.0
      @[GLFunction("glFlushMappedBufferRange", version: "3.0")]
      @[AlwaysInline]
      def flush
        start = Size.new!(0)
        count = Size.new(mapping.size)
        flush(start, count)
      end

      # Flushes a subset of the mapped buffer to indicate changes have been made.
      #
      # See: `Buffer#flush`
      #
      # - OpenGL function: `glFlushMappedBufferRange`
      # - OpenGL version: 3.0
      @[GLFunction("glFlushMappedBufferRange", version: "3.0")]
      def flush(start : Size, count : Size)
        gl.flush_mapped_buffer_range(to_unsafe, start, count)
      end

      # Flushes a subset of the mapped buffer to indicate changes have been made.
      #
      # See: `Buffer#flush`
      #
      # - OpenGL function: `glFlushMappedBufferRange`
      # - OpenGL version: 3.0
      @[GLFunction("glFlushMappedBufferRange", version: "3.0")]
      @[AlwaysInline]
      def flush(range : Range)
        start = Size.new(range.begin)
        count = Size.new(range.size)
        flush(start, count)
      end

      # Retrieves information about the bound buffer's current map.
      #
      # Returns nil if the buffer isn't mapped.
      #
      # See: `Buffer#mapping?`
      def mapping? : TargetMap?
        return unless mapped?

        TargetMap.new(context, target)
      end

      # Retrieves information about the bound buffer's current map.
      #
      # Raises if the buffer isn't mapped.
      #
      # See: `Buffer#mapping`
      def mapping : TargetMap
        mapping? || raise NilAssertionError.new("Buffer not mapped")
      end

      # Returns an OpenGL enum representing this buffer binding target.
      def to_unsafe
        @target.to_unsafe
      end

      # Returns an OpenGL enum representing this buffer binding target.
      # This intended to be used with `glBufferStorage` since it uses a different enum group.
      protected def storage_target
        LibGL::BufferStorageTarget.new(@target.value)
      end

      # Returns an OpenGL enum representing this buffer binding target.
      # This intended to be used with `glCopyBufferSubData` since it uses a different enum group.
      protected def copy_buffer_target
        LibGL::CopyBufferSubDataTarget.new(@target.value)
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
    end
  end
end
