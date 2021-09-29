require "./buffer/bind_target"
require "./buffer/target"
require "./contextual"

module Gloop
  struct Buffers
    include Contextual

    private macro buffer_target(name)
      def {{name.id}}
        Buffer::BindTarget.new(@context, {{name.id.symbolize}})
      end
    end

    buffer_target :array

    buffer_target :element_array

    buffer_target :pixel_pack

    buffer_target :pixel_unpack

    buffer_target :transform_feedback

    buffer_target :texture

    buffer_target :copy_read

    buffer_target :copy_write

    buffer_target :uniform

    buffer_target :draw_indirect

    buffer_target :atomic_counter

    buffer_target :dispatch_indirect

    buffer_target :shader_storage

    buffer_target :query

    buffer_target :parameter

    def [](target : Buffer::Target)
      Buffer::BindTarget.new(@context, target)
    end

    # Copies a subset of data from a buffer bound to one target into one bound by another target.
    def copy(from read_target : Buffer::Target, to write_target : Buffer::Target,
             read_offset : Int, write_offset : Int, size : Int)
      Buffer::BindTarget.copy(read_target, write_target, read_offset, write_offset, size)
    end
  end

  struct Context
    def buffers
      Buffers.new(self)
    end
  end
end
