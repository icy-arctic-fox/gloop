require "./context"

module Gloop
  # Identifier for an toggleable OpenGL capability.
  enum Capability : LibGL::Enum
    LineSmooth                 = LibGL::EnableCap::LineSmooth
    PolygonSmooth              = LibGL::EnableCap::PolygonSmooth
    CullFace                   = LibGL::EnableCap::CullFace
    DepthTest                  = LibGL::EnableCap::DepthTest
    StencilTest                = LibGL::EnableCap::StencilTest
    Dither                     = LibGL::EnableCap::Dither
    Blend                      = LibGL::EnableCap::Blend
    ScissorTest                = LibGL::EnableCap::ScissorTest
    Texture1D                  = LibGL::EnableCap::Texture1D
    Texture2D                  = LibGL::EnableCap::Texture2D
    ColorLogicOp               = LibGL::EnableCap::ColorLogicOp
    PolygonOffsetPoint         = LibGL::EnableCap::PolygonOffsetPoint
    PolygonOffsetLine          = LibGL::EnableCap::PolygonOffsetLine
    PolygonOffsetFill          = LibGL::EnableCap::PolygonOffsetFill
    Multisample                = LibGL::EnableCap::Multisample
    SampleAlphaToCoverage      = LibGL::EnableCap::SampleAlphaToCoverage
    SampleAlphaToOne           = LibGL::EnableCap::SampleAlphaToOne
    SampleCoverage             = LibGL::EnableCap::SampleCoverage
    ClipDistance0              = LibGL::EnableCap::ClipDistance0
    ClipPlane0                 = LibGL::EnableCap::ClipPlane0
    ClipDistance1              = LibGL::EnableCap::ClipDistance1
    ClipPlane1                 = LibGL::EnableCap::ClipPlane1
    ClipDistance2              = LibGL::EnableCap::ClipDistance2
    ClipPlane2                 = LibGL::EnableCap::ClipPlane2
    ClipDistance3              = LibGL::EnableCap::ClipDistance3
    ClipPlane3                 = LibGL::EnableCap::ClipPlane3
    ClipDistance4              = LibGL::EnableCap::ClipDistance4
    ClipPlane4                 = LibGL::EnableCap::ClipPlane4
    ClipDistance5              = LibGL::EnableCap::ClipDistance5
    ClipPlane5                 = LibGL::EnableCap::ClipPlane5
    ClipDistance6              = LibGL::EnableCap::ClipDistance6
    ClipDistance7              = LibGL::EnableCap::ClipDistance7
    RasterizerDiscard          = LibGL::EnableCap::RasterizerDiscard
    FramebufferSRGB            = LibGL::EnableCap::FramebufferSRGB
    PrimitiveRestart           = LibGL::EnableCap::PrimitiveRestart
    ProgramPointSize           = LibGL::EnableCap::ProgramPointSize
    VertexProgramPointSize     = LibGL::EnableCap::VertexProgramPointSize
    DepthClamp                 = LibGL::EnableCap::DepthClamp
    TextureCubeMapSeamless     = LibGL::EnableCap::TextureCubeMapSeamless
    SampleMask                 = LibGL::EnableCap::SampleMask
    SampleShading              = LibGL::EnableCap::SampleShading
    PrimitiveRestartFixedIndex = LibGL::EnableCap::PrimitiveRestartFixedIndex
    DebugOutputSynchronous     = LibGL::EnableCap::DebugOutputSynchronous
    VertexArray                = LibGL::EnableCap::VertexArray
    DebugOutput                = LibGL::EnableCap::DebugOutput

    # Enables the capability.
    #
    # Effectively calls:
    # ```c
    # glEnable(capability)
    # ```
    #
    # Minimum required version: 2.0
    def enable
      Gloop::Context.enable(self)
    end

    # Disables the capability.
    #
    # Effectively calls:
    # ```c
    # glDisable(capability)
    # ```
    #
    # Minimum required version: 2.0
    def disable
      Gloop::Context.disable(self)
    end

    # Checks if the capability is enabled.
    #
    # Effectively calls:
    # ```c
    # glIsEnabled(capability)
    # ```
    #
    # Minimum required version: 2.0
    def enabled?
      Gloop::Context.enabled?(self)
    end

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::EnableCap.new(value)
    end
  end
end
