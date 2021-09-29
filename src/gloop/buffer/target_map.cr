require "../contextual"
require "../size"
require "./access"
require "./access_mask"
require "./parameters"

module Gloop
  struct Buffer < Object
    # Reference to a buffer mapping via a binding target.
    struct TargetMap
      include Contextual
      include Parameters

      # When the buffer is mapped, gives the number of bytes mapped.
      #
      # - OpenGL function: `glGetBufferParameteriv`, `glGetBufferParameteri64v`
      # - OpenGL enum: `GL_BUFFER_MAP_LENGTH`
      # - OpenGL version: 2.0, 3.2
      {% if flag?(:x86_64) %}
        @[GLFunction("glGetBufferParameteri64v", enum: "GL_BUFFER_MAP_LENGTH", version: "3.2")]
      {% else %}
        @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_MAP_LENGTH", version: "2.0")]
      {% end %}
      buffer_target_parameter BufferMapLength, size : Size

      # When the buffer is mapped, gives the offset (in bytes) of the mapped region.
      #
      # - OpenGL function: `glGetBufferParameteriv`, `glGetBufferParameteri64v`
      # - OpenGL enum: `GL_BUFFER_MAP_OFFSET`
      # - OpenGL version: 3.0, 3.2
      {% if flag?(:x86_64) %}
        @[GLFunction("glGetBufferParameteri64v", enum: "GL_BUFFER_MAP_OFFSET", version: "3.2")]
      {% else %}
        @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_MAP_OFFSET", version: "3.0")]
      {% end %}
      buffer_target_parameter BufferMapOffset, offset : Size

      # Retrieves the access policy previously set when `Buffer#map` or `BindTarget#map` was called.
      #
      # - OpenGL function: `glGetBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_ACCESS`
      # - OpenGL version: 2.0
      @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_ACCESS", version: "2.0")]
      buffer_target_parameter BufferAccess, access : Access

      # Retrieves the access mask previously used when `Buffer#map` or `BindTarget#map` was called with a subset.
      #
      # - OpenGL function: `glGetBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_ACCESS_FLAGS`
      # - OpenGL version: 2.0
      @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_ACCESS_FLAGS", version: "2.0")]
      buffer_target_parameter BufferAccessFlags, access_mask : AccessMask

      # Buffer binding target.
      private getter target : Target

      # Creates the mapping reference.
      def initialize(@context : Context, @target : Target)
      end

      # Retrieves the bytes referring to the mapped data.
      def to_slice : Bytes
        pointer = to_unsafe.as(UInt8*)
        Bytes.new(pointer, size)
      end

      # Retrieves a pointer to the start of the mapped data.
      #
      # - OpenGL function: `glGetBufferPointerv`
      # - OpenGL enum: `GL_BUFFER_MAP_POINTER`
      # - OpenGL version: 2.0
      @[GLFunction("glGetBufferPointerv", enum: "GL_BUFFER_MAP_POINTER", version: "2.0")]
      def to_unsafe
        value = uninitialized Void*
        gl.get_buffer_pointer_v(@target.to_unsafe, LibGL::BufferPointerNameARB::BufferMapPointer, pointerof(value))
        value.as(UInt8*)
      end
    end
  end
end
