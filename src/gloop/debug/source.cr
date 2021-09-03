module Gloop::Debug
  # Debug message sources.
  enum Source : LibGL::Enum
    # Used for filtering messages.
    DontCare = LibGL::DebugSource::DontCare

    # OpenGL API call.
    API = LibGL::DebugSource::DebugSourceAPI

    # Window system API.
    WindowSystem = LibGL::DebugSource::DebugSourceWindowSystem

    # Shader compiler.
    ShaderCompiler = LibGL::DebugSource::DebugSourceShaderCompiler

    # Application associated with OpenGL.
    ThirdParty = LibGL::DebugSource::DebugSourceThirdParty

    # Client generated.
    Application = LibGL::DebugSource::DebugSourceApplication

    # None of the above.
    Other = LibGL::DebugSource::DebugSourceOther

    # Converts to an OpenGL enum.
    def to_unsafe
      LibGL::DebugSource.new(value)
    end
  end
end
