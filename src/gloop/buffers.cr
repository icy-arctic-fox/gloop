require "./buffer/bind_target"
require "./buffer/target"
require "./contextual"
require "./size"

module Gloop
  # Reference to all buffer binding targets for a context.
  struct Buffers
    include Contextual

    # Defines a method that returns a buffer binding target for the specified target.
    #
    # The *target* should be a symbol that refers to an enum value in `Buffer::Target`.
    private macro buffer_target(target)
      def {{target.id}} : Buffer::BindTarget
        Buffer::BindTarget.new(@context, {{target.id.symbolize}})
      end
    end

    # Retrieves a binding target for array buffers.
    buffer_target :array

    # Retrieves a binding target for element array buffers.
    buffer_target :element_array

    # Retrieves a binding target for pixel pack buffers.
    buffer_target :pixel_pack

    # Retrieves a binding target for pixel unpack buffers.
    buffer_target :pixel_unpack

    # Retrieves a binding target for transform feedback buffers.
    buffer_target :transform_feedback

    # Retrieves a binding target for texture buffers.
    buffer_target :texture

    # Retrieves a binding target for read buffers.
    buffer_target :copy_read

    # Retrieves a binding target for write buffers.
    buffer_target :copy_write

    # Retrieves a binding target for uniform buffers.
    buffer_target :uniform

    # Retrieves a binding target for indirect draw buffers.
    buffer_target :draw_indirect

    # Retrieves a binding target for atomic counter buffers.
    buffer_target :atomic_counter

    # Retrieves a binding target for indirect dispatch buffers.
    buffer_target :dispatch_indirect

    # Retrieves a binding target for shader storage buffers.
    buffer_target :shader_storage

    # Retrieves a binding target for query buffers.
    buffer_target :query

    # Retrieves a binding target for parameter buffers.
    buffer_target :parameter

    # Retrieves the specified buffer binding target.
    def [](target : Buffer::Target) : Buffer::BindTarget
      Buffer::BindTarget.new(@context, target)
    end

    # Copies a subset of data from a buffer bound to one target into one bound by another target.
    #
    # The *read_offset* indicates the byte offset to start copying from *read_target*.
    # The *write_offset* indicates the byte offset to start copying into *write_target*.
    # The *size* is the number of bytes to copy.
    #
    # - OpenGL function: `glCopyBufferSubData`
    # - OpenGL version: 3.1
    @[GLFunction("glCopyBufferSubData", version: "3.1")]
    def copy(from read_target : Buffer::Target, to write_target : Buffer::Target,
             read_offset : Size, write_offset : Size, size : Size) : Nil
      gl.copy_buffer_sub_data(
        read_target.copy_buffer_target, write_target.copy_buffer_target, read_offset, write_offset, size)
    end
  end

  struct Context
    # Retrieves an interface for the buffer binding targets for this context.
    def buffers : Buffers
      Buffers.new(self)
    end
  end
end
