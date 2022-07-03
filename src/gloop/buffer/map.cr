require "../contextual"
require "../size"
require "./access"
require "./access_mask"
require "./parameters"

module Gloop
  struct Buffer < Object
    # Reference to a buffer mapping.
    struct Map
      include Contextual
      include Parameters

      {% if flag?(:x86_64) %}
        # When the buffer is mapped, gives the number of bytes mapped.
        #
        # See: `TargetMap#size`
        #
        # - OpenGL function: `glGetNamedBufferParameteri64v`
        # - OpenGL enum: `GL_BUFFER_MAP_LENGTH`
        # - OpenGL version: 4.5
        @[GLFunction("glGetNamedBufferParameteri64v", enum: "GL_BUFFER_MAP_LENGTH", version: "4.5")]
        buffer_parameter BufferMapLength, size : Size

        # When the buffer is mapped, gives the offset (in bytes) of the mapped region.
        #
        # See: `TargetMap#offset`
        #
        # - OpenGL function: `glGetNamedBufferParameteri64v`
        # - OpenGL enum: `GL_BUFFER_MAP_OFFSET`
        # - OpenGL version: 4.5
        @[GLFunction("glGetNamedBufferParameteri64v", enum: "GL_BUFFER_MAP_OFFSET", version: "4.5")]
        buffer_parameter BufferMapOffset, offset : Size
      {% else %}
        # When the buffer is mapped, gives the number of bytes mapped.
        #
        # See: `TargetMap#size`
        #
        # - OpenGL function: `glGetNamedBufferParameteriv`
        # - OpenGL enum: `GL_BUFFER_MAP_LENGTH`
        # - OpenGL version: 4.5
        @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_MAP_LENGTH", version: "4.5")]
        buffer_parameter BufferMapLength, size : Size

        # When the buffer is mapped, gives the offset (in bytes) of the mapped region.
        #
        # See: `TargetMap#offset`
        #
        # - OpenGL function: `glGetNamedBufferParameteriv`
        # - OpenGL enum: `GL_BUFFER_MAP_OFFSET`
        # - OpenGL version: 4.5
        @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_MAP_OFFSET", version: "4.5")]
        buffer_parameter BufferMapOffset, offset : Size
      {% end %}

      # Retrieves the access policy previously set when `Buffer#map` or `BindTarget#map` was called.
      #
      # See: `TargetMap#access`
      #
      # - OpenGL function: `glGetNamedBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_ACCESS`
      # - OpenGL version: 4.5
      @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_ACCESS", version: "4.5")]
      buffer_parameter BufferAccess, access : Access

      # Retrieves the access mask previously used when `Buffer#map` or `BindTarget#map` was called with a subset.
      #
      # See: `TargetMap#access_flags`
      #
      # - OpenGL function: `glGetNamedBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_ACCESS_FLAGS`
      # - OpenGL version: 4.5
      @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_ACCESS_FLAGS", version: "4.5")]
      buffer_parameter BufferAccessFlags, access_mask : AccessMask

      # Context associated with the buffer mapping.
      private getter context : Context

      # Name of the buffer.
      private getter name : Name

      # Creates the mapping reference.
      def initialize(@context : Context, @name : Name)
      end

      # Retrieves the bytes referring to the mapped data.
      def to_slice : Bytes
        Bytes.new(to_unsafe, size)
      end

      # Retrieves a pointer to the start of the mapped data.
      #
      # See: `TargetMap#to_unsafe`
      #
      # - OpenGL function: `glGetNamedBufferPointerv`
      # - OpenGL enum: `GL_BUFFER_MAP_POINTER`
      # - OpenGL version: 4.5
      @[GLFunction("glGetNamedBufferPointerv", enum: "GL_BUFFER_MAP_POINTER", version: "4.5")]
      def to_unsafe
        value = uninitialized Void*
        gl.get_named_buffer_pointer_v(@name, LibGL::BufferPointerNameARB::BufferMapPointer, pointerof(value))
        value.as(UInt8*)
      end
    end
  end
end
