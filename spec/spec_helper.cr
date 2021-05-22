require "glfw"
require "opengl"
require "spectator"
require "../src/gloop"

# Initializes OpenGL enough for testing.
def init_opengl
  LibGLFW.init
  LibGLFW.window_hint(LibGLFW::WindowHint::Visible, LibGLFW::Bool::False)
  LibGLFW.window_hint(LibGLFW::WindowHint::ContextVersionMajor, 4)
  LibGLFW.window_hint(LibGLFW::WindowHint::ContextVersionMinor, 6)
  LibGLFW.window_hint(LibGLFW::WindowHint::ClientAPI, LibGLFW::ClientAPI::OpenGL)
  LibGLFW.window_hint(LibGLFW::WindowHint::OpenGLProfile, LibGLFW::OpenGLProfile::Core)
  LibGLFW.window_hint(LibGLFW::WindowHint::OpenGLDebugContext, LibGLFW::Bool::True)
  window = LibGLFW.create_window(640, 480, "Gloop", nil, nil)
  LibGLFW.make_context_current(window)
end

# Cleans up resources used by OpenGL and GLFW.
def terminate_opengl
  LibGLFW.terminate
end
