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

      {% if flag?(:x86_64) %}
        # When the buffer is mapped, gives the number of bytes mapped.
        #
        # See: `Map#size`
        #
        # - OpenGL function: `glGetBufferParameteri64v`
        # - OpenGL enum: `GL_BUFFER_MAP_LENGTH`
        # - OpenGL version: 3.2
        @[GLFunction("glGetBufferParameteri64v", enum: "GL_BUFFER_MAP_LENGTH", version: "3.2")]
        buffer_target_parameter BufferMapLength, size : Size

        # When the buffer is mapped, gives the offset (in bytes) of the mapped region.
        #
        # See: `Map#offset`
        #
        # - OpenGL function: `glGetBufferParameteri64v`
        # - OpenGL enum: `GL_BUFFER_MAP_OFFSET`
        # - OpenGL version: 3.2
        @[GLFunction("glGetBufferParameteri64v", enum: "GL_BUFFER_MAP_OFFSET", version: "3.2")]
        buffer_target_parameter BufferMapOffset, offset : Size
      {% else %}
        # When the buffer is mapped, gives the number of bytes mapped.
        #
        # See: `Map#size`
        #
        # - OpenGL function: `glGetBufferParameteriv`
        # - OpenGL enum: `GL_BUFFER_MAP_LENGTH`
        # - OpenGL version: 2.0
        @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_MAP_LENGTH", version: "2.0")]
        buffer_target_parameter BufferMapLength, size : Size

        # When the buffer is mapped, gives the offset (in bytes) of the mapped region.
        #
        # See: `Map#offset`
        #
        # - OpenGL function: `glGetBufferParameteriv`
        # - OpenGL enum: `GL_BUFFER_MAP_OFFSET`
        # - OpenGL version: 3.0
        @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_MAP_OFFSET", version: "3.0")]
        buffer_target_parameter BufferMapOffset, offset : Size
      {% end %}

      # Retrieves the access policy previously set when `Buffer#map` or `BindTarget#map` was called.
      #
      # See: `Map#access`
      #
      # - OpenGL function: `glGetBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_ACCESS`
      # - OpenGL version: 2.0
      @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_ACCESS", version: "2.0")]
      buffer_target_parameter BufferAccess, access : Access

      # Retrieves the access mask previously used when `Buffer#map` or `BindTarget#map` was called with a subset.
      #
      # See: `Map#access_mask`
      #
      # - OpenGL function: `glGetBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_ACCESS_FLAGS`
      # - OpenGL version: 2.0
      @[GLFunction("glGetBufferParameteriv", enum: "GL_BUFFER_ACCESS_FLAGS", version: "2.0")]
      buffer_target_parameter BufferAccessFlags, access_mask : AccessMask

      # Context associated with the mapping.
      private getter context : Context

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
      # See: `Map#to_unsafe`
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
