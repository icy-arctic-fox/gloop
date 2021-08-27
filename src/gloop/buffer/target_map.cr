require "../error_handling"
require "./access"
require "./access_mask"
require "./buffer_target_parameters"

module Gloop
  struct Buffer < Object
    # Reference to a buffer mapping via a binding target.
    struct TargetMap
      include BufferTargetParameters
      include ErrorHandling

      # When the buffer is mapped, gives the number of bytes mapped.
      buffer_parameter BufferMapLength, size

      # When the buffer is mapped, gives the offset (in bytes) of the mapped region.
      buffer_parameter BufferMapOffset, offset

      # Retrieves the access policy previously set when `Buffer#map` or `BindTarget#map` was called.
      buffer_parameter BufferAccess, access do |value|
        Access.new(value.to_u32)
      end

      # Retrieves the access mask previously used when `Buffer#map` or `BindTarget#map` was called with a subset.
      buffer_parameter BufferAccessFlags, access_mask do |value|
        AccessMask.new(value.to_u32)
      end

      # Buffer binding target.
      private getter target : Target

      # Creates the mapping reference.
      def initialize(@target : Target)
      end

      # Retrieves the bytes referring to the mapped data.
      def to_slice : Bytes
        pointer = to_unsafe.as(UInt8*)
        Bytes.new(pointer, size)
      end

      # Retrieves a pointer to the start of the mapped data.
      def to_unsafe
        checked do
          LibGL.get_buffer_pointer_v(@target, LibGL::BufferPointerNameARB::BufferMapPointer, out value)
          value
        end
      end
    end
  end
end
