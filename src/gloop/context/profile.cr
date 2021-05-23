require "opengl"

module Gloop::Context
  # Profile an OpenGL context is utilizing.
  # See: https://www.khronos.org/opengl/wiki/OpenGL_Context#OpenGL_3.2_and_Profiles
  enum Profile
    # OpenGL specification without deprecated features.
    # Available on all systems.
    Core = LibGL::ContextProfileMask::ContextCoreProfile

    # OpenGL specification with deprecated features.
    # Not available on all systems.
    Compatibility = LibGL::ContextProfileMask::ContextCompatibilityProfile
  end
end
