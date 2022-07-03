require "./contextual"

module Gloop
  # Reference to an OpenGL capability for a context.
  struct Capability
    include Contextual

    # Identifier for an toggleable OpenGL capability.
    enum Enum : LibGL::Enum
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

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::EnableCap.new(value)
      end
    end

    # Context associated with the attribute reference.
    private getter context : Context

    # Creates a reference to an OpenGL capability for a context.
    def initialize(@context : Context, @value : Enum)
    end

    # Enables this capability.
    #
    # - OpenGL function: `glEnable`
    # - OpenGL version: 2.0
    @[GLFunction("glEnable", version: "2.0")]
    def enable : Nil
      gl.enable(to_unsafe)
    end

    # Disables this capability.
    #
    # - OpenGL function: `glDisable`
    # - OpenGL version: 2.0
    @[GLFunction("glDisable", version: "2.0")]
    def disable : Nil
      gl.disable(to_unsafe)
    end

    # Checks if this capability is enabled.
    #
    # - OpenGL function: `glIsEnabled`
    # - OpenGL version: 2.0
    @[GLFunction("glIsEnabled", version: "2.0")]
    def enabled?
      value = gl.is_enabled(to_unsafe)
      !value.false?
    end

    # Enables or disables this capability based on a given *flag*.
    #
    # - OpenGL function: `glEnable`, `glDisable`
    # - OpenGL version: 2.0
    @[GLFunction("glEnable", version: "2.0")]
    @[GLFunction("glDisable", version: "2.0")]
    @[AlwaysInline]
    def enabled=(flag)
      flag ? enable : disable
    end

    # Converts to an OpenGL enum.
    def to_unsafe
      @value.to_unsafe
    end
  end

  struct Context
    # Retrieves a reference to the specified capability for this context.
    def capability(value : Capability::Enum) : Capability
      Capability.new(self, value)
    end

    # Enables the specified capability for this context.
    #
    # See: `Capability#enable`
    def enable(value : Capability::Enum)
      Capability.new(self, value).tap(&.enable)
    end

    # Disables the specified capability for this context.
    #
    # See: `Capability#disable`
    def disable(value : Capability::Enum)
      Capability.new(self, value).tap(&.disable)
    end

    # Checks if the specified capability for this context is enabled.
    #
    # See: `Capability#enabled?`
    def enabled?(value : Capability::Enum)
      Capability.new(self, value).enabled?
    end
  end
end
