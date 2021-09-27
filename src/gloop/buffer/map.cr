require "../contextual"
require "./access"
require "./access_mask"
require "./parameters"

module Gloop
  struct Buffer < Object
    # Reference to a buffer mapping.
    struct Map
      include Contextual
      include Parameters

      # Integer type used for size-related operations.
      # OpenGL functions will use 32-bit or 64-bit integers depending on the system architecture.
      {% if flag?(:x86_64) %}
        alias Size = Int64
      {% else %}
        alias Size = Int32
      {% end %}

      # When the buffer is mapped, gives the number of bytes mapped.
      buffer_parameter BufferMapLength, size : Size

      # When the buffer is mapped, gives the offset (in bytes) of the mapped region.
      buffer_parameter BufferMapOffset, offset : Size

      # Retrieves the access policy previously set when `Buffer#map` or `BindTarget#map` was called.
      buffer_parameter BufferAccess, access : Access

      # Retrieves the access mask previously used when `Buffer#map` or `BindTarget#map` was called with a subset.
      buffer_parameter BufferAccessFlags, access_mask : AccessMask

      # Name of the buffer.
      private getter name : UInt32

      # Creates the mapping reference.
      def initialize(@context : Context, @name : UInt32)
      end

      # Retrieves the bytes referring to the mapped data.
      def to_slice : Bytes
        Bytes.new(to_unsafe, size)
      end

      # Retrieves a pointer to the start of the mapped data.
      def to_unsafe
        value = uninitialized Void*
        gl.get_named_buffer_pointer_v(@name, LibGL::BufferPointerNameARB::BufferMapPointer, pointerof(value))
        value.as(UInt8*)
      end
    end
  end
end
