require "../error_handling"
require "./buffer_target_parameters"
require "./target"

module Gloop
  struct Buffer < Object
    struct BindTarget
      include BufferTargetParameters
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

      getter target : Target

      protected def initialize(@target : Target)
      end

      # Retrieves the buffer currently bound to this target.
      # If there is no buffer bound, nil is returned.
      def buffer : Buffer?
        pname = binding_pname
        name = checked do
          LibGL.get_integer_v(pname, out name)
          name
        end
        Buffer.new(name.to_u32!) unless name.zero?
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
        checked { LibGL.bind_buffer(self, buffer) }
      end

      # Unbinds any previously bound buffer from this target.
      def unbind
        checked { LibGL.bind_buffer(self, 0) }
      end

      # Stores data in the buffer currently bound to this target.
      # The *data* must have a `#to_slice` method.
      # The `Bytes`, `Slice`, and `StaticArray` types are ideal for this.
      def data(data, usage : Usage)
        slice = data.to_slice
        size = slice.bytesize
        checked { LibGL.buffer_data(self, size, slice, usage) }
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
          checked { LibGL.get_buffer_sub_data(self, 0, bytes.bytesize, bytes) }
        end
      end

      # Retrieves a subset of data from the buffer currently bound to this target.
      def []?(start : Int, count : Int) : Bytes?
        start, count = Indexable.normalize_start_and_count(start, count, size) { return nil }
        Bytes.new(count).tap do |bytes|
          checked { LibGL.get_buffer_sub_data(self, start, count, bytes) }
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
          checked { LibGL.get_buffer_sub_data(self, start, count, bytes) }
        end
      end

      # Retrieves a range of data from the buffer currently bound to this target
      def [](range : Range) : Bytes
        self[range]? || raise IndexError.new
      end

      # Returns an OpenGL enum representing this buffer binding target.
      def to_unsafe
        @target.to_unsafe
      end
    end
  end
end
