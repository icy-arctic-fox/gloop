require "./buffer/bind_target"

module Gloop
  module Buffers
    extend self

    private macro buffer_target(name)
      def {{name.id}}
        Buffer::BindTarget.new({{name.id.symbolize}})
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
      Buffer::BindTarget.new(target)
    end
  end
end
