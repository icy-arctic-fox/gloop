require "opengl"

module Gloop
  abstract struct Buffer
    # Reference to a buffer's mapped contents in application memory.
    struct Map
      # Provides access to the mapped memory.
      getter data : Bytes

      # Creates a wrapper for mapped buffer memory.
      protected def initialize(@buffer : UInt32, @data : Bytes)
      end

      # Retrieves the access policy that was specified when the buffer was mapped.
      def access
        value = checked do
          LibGL.get_named_buffer_parameter_iv(@buffer, LibGL::VertexBufferObjectParameter::BufferAccessFlags, out params)
          params
        end
        Access.from_value(value)
      end

      # Indicates changes have been made to the buffer mapping.
      # The buffer must be mapped with `Access::FlushExplicit` to use this.
      def flush
        flush(0, size)
      end

      # Indicates changes have been made to a portion of the buffer mapping.
      # The buffer must be mapped with `Access::FlushExplicit` to use this.
      def flush(range : Range)
        start, count = Indexable.range_to_index_and_count(range, size)
        flush(start, count)
      end

      # Indicates changes have been made to a portion of the buffer mapping.
      # The buffer must be mapped with `Access::FlushExplicit` to use this.
      def flush(start : Int, count : Int)
        checked { LibGL.flush_mapped_named_buffer_range(@buffer, start, count) }
      end

      # Retrieves the offset into the buffer (in bytes) where the mapping starts.
      def offset
        checked do
          LibGL.get_named_buffer_parameter_i64v(@buffer, LibGL::VertexBufferObjectParameter::BufferMapOffset, out params)
          params
        end
      end

      # Retrieves the size (in bytes) of the mapped memory.
      def size
        @data.size
      end

      # Retrieves a slice of memory pointing to the mapped memory.
      def to_slice
        @data
      end

      # Returns a pointer to the mapped memory.
      def to_unsafe
        @data.to_unsafe
      end

      # Unmaps the buffer from the client application's memory.
      # Returns false if the buffer's contents have become corrupt while the buffer was mapped.
      def unmap
        value = expect_truthy { LibGL.unmap_named_buffer(@buffer) }
        int_to_bool(value)
      end

      # Specifies the type of access the application has to a mapped buffer's contents.
      @[Flags]
      enum Access
        # The application is allowed to read from the mapped contents.
        Read = LibGL::MapBufferAccessMask::MapRead

        # The application is allowed to write to the mapped contents.
        Write = LibGL::MapBufferAccessMask::MapWrite

        # Enables flushing regions of mapped content.
        FlushExplicit = LibGL::MapBufferAccessMask::MapFlushExplicit

        # Converts to an OpenGL enum.
        def to_unsafe
          LibGL::MapBufferAccessMask.new(value)
        end
      end
    end
  end
end
