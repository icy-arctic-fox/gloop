require "opengl"

module Gloop
  struct DebugMessage
    # System the message came from.
    enum Source : UInt32
      Unknown = LibGL::DebugSource::DontCare

      API = LibGL::DebugSource::DebugSourceApi

      WindowSystem = LibGL::DebugSource::DebugSourceWindowSystem

      ShaderCompiler = LibGL::DebugSource::DebugSourceShaderCompiler

      ThirdParty = LibGL::DebugSource::DebugSourceThirdParty

      Application = LibGL::DebugSource::DebugSourceApplication

      Other = LibGL::DebugSource::DebugSourceOther
    end
  end
end
