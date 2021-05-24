module Gloop::Debug
  # Debug message sources.
  enum Source
    # Used for filtering messages.
    DontCare = LibGL::DebugSource::DontCare

    # OpenGL API call.
    API = LibGL::DebugSource::DebugSourceApi

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
  end
end
