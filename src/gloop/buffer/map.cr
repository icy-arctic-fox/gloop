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

      # When the buffer is mapped, gives the number of bytes mapped.
      #
      # - OpenGL function: `glGetNamedBufferParameteriv`, `glGetNamedBufferParameteri64v`
      # - OpenGL enum: `GL_BUFFER_MAP_LENGTH`
      # - OpenGL version: 4.5
      {% if flag?(:x86_64) %}
        @[GLFunction("glGetNamedBufferParameteri64v", enum: "GL_BUFFER_MAP_LENGTH", version: "4.5")]
      {% else %}
        @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_MAP_LENGTH", version: "4.5")]
      {% end %}
      buffer_parameter BufferMapLength, size : Size

      # When the buffer is mapped, gives the offset (in bytes) of the mapped region.
      #
      # - OpenGL function: `glGetNamedBufferParameteriv`, `glGetNamedBufferParameteri64v`
      # - OpenGL enum: `GL_BUFFER_MAP_OFFSET`
      # - OpenGL version: 4.5
      {% if flag?(:x86_64) %}
        @[GLFunction("glGetNamedBufferParameteri64v", enum: "GL_BUFFER_MAP_OFFSET", version: "4.5")]
      {% else %}
        @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_MAP_OFFSET", version: "4.5")]
      {% end %}
      buffer_parameter BufferMapOffset, offset : Size

      # Retrieves the access policy previously set when `Buffer#map` or `BindTarget#map` was called.
      #
      # - OpenGL function: `glGetNamedBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_ACCESS`
      # - OpenGL version: 4.5
      @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_ACCESS", version: "4.5")]
      buffer_parameter BufferAccess, access : Access

      # Retrieves the access mask previously used when `Buffer#map` or `BindTarget#map` was called with a subset.
      #
      # - OpenGL function: `glGetNamedBufferParameteriv`
      # - OpenGL enum: `GL_BUFFER_ACCESS_FLAGS`
      # - OpenGL version: 4.5
      @[GLFunction("glGetNamedBufferParameteriv", enum: "GL_BUFFER_ACCESS_FLAGS", version: "4.5")]
      buffer_parameter BufferAccessFlags, access_mask : AccessMask

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
