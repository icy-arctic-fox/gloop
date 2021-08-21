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

      # Binds a buffer to this target.
      def bind(buffer)
        checked { LibGL.bind_buffer(self, buffer) }
      end

      # Stores data in the buffer currently bound to this target.
      # The *data* must have `#bytesize` and `#to_unsafe` methods.
      # The `Bytes` (`Slice`) type is ideal for this.
      def data(data, usage : Usage)
        size = data.bytesize
        checked { LibGL.buffer_data(self, size, data, usage) }
      end

      # Stores data in the buffer currently bound to this target.
      # The *data* must have `#bytesize` and `#to_unsafe` methods.
      # The `Bytes` (`Slice`) type is ideal for this.
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
