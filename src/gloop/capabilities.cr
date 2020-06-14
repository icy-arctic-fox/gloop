require "opengl"
require "./bool_conversion"
require "./capability"
require "./error_handling"

module Gloop
  # Queries and enables or disables OpenGL capabilities and features.
  module Capabilities
    extend self

    # Creates a capability getter.
    # The *name* is the name used to define the method.
    # The *pname* is the enum value of the capability.
    # This should be an enum value from `LibGL::EnableCap`.
    private macro capability(name, pname)
      def {{name.id}}
        Capability.new(LibGL::EnableCap::{{pname.id}})
      end
    end

    capability blend, Blend

    capability color_logic_operator, ColorLogicOp

    capability cull_face, CullFace

    capability debug_output, DebugOutput

    capability debug_output_synchronous, DebugOutputSynchronous

    capability depth_clamp, DepthClamp

    capability depth_test, DepthTest

    capability dither, Dither

    capability framebuffer_srgb, FramebufferSrGB

    capability line_smooth, LineSmooth

    capability multisample, Multisample

    capability polygon_offset_fill, PolygonOffsetFill

    capability polygon_offset_line, PolygonOffsetLine

    capability polygon_offset_point, PolygonOffsetPoint

    capability polygon_smooth, PolygonSmooth

    capability primitive_restart, PrimitiveRestart

    capability primitive_restart_fixed_index, PrimitiveRestartFixedIndex

    capability rasterizer_discard, RasterizerDiscard

    capability sample_alpha_to_coverage, SampleAlphaToCoverage

    capability sample_alpha_to_one, SampleAlphaToOne

    capability sample_coverage, SampleCoverage

    capability sample_shading, SampleShading

    capability sample_mask, SampleMask

    capability scissor_test, ScissorTest

    capability stencil_test, StencilTest

    capability texture_cube_map_seamless, TextureCubeMapSeamless

    capability program_point_size, ProgramPointSize

    def clip_distance(index)
      value = case index
              when 0 then LibGL::EnableCap::ClipDistance0
              when 1 then LibGL::EnableCap::ClipDistance1
              when 2 then LibGL::EnableCap::ClipDistance2
              when 3 then LibGL::EnableCap::ClipDistance3
              when 4 then LibGL::EnableCap::ClipDistance4
              when 5 then LibGL::EnableCap::ClipDistance5
              when 6 then LibGL::EnableCap::ClipDistance6
              when 7 then LibGL::EnableCap::ClipDistance7
              else
                raise IndexError.new
              end

      Capability.new(value)
    end
  end
end
