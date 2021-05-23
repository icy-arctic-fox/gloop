require "glfw"
require "opengl"
require "spectator"
require "../src/gloop"

# Initializes OpenGL enough for testing.
def init_opengl
  checked { LibGLFW.init }
  LibGLFW.window_hint(LibGLFW::WindowHint::Visible, LibGLFW::Bool::False)
  LibGLFW.window_hint(LibGLFW::WindowHint::ContextVersionMajor, 4)
  LibGLFW.window_hint(LibGLFW::WindowHint::ContextVersionMinor, 6)
  LibGLFW.window_hint(LibGLFW::WindowHint::ClientAPI, LibGLFW::ClientAPI::OpenGL)
  LibGLFW.window_hint(LibGLFW::WindowHint::OpenGLProfile, LibGLFW::OpenGLProfile::Core)
  LibGLFW.window_hint(LibGLFW::WindowHint::OpenGLDebugContext, LibGLFW::Bool::True)
  window = checked { LibGLFW.create_window(640, 480, "Gloop", nil, nil) }
  LibGLFW.make_context_current(window)
end

# Cleans up resources used by OpenGL and GLFW.
def terminate_opengl
  LibGLFW.terminate
end

private def checked
  value = yield
  error = LibGLFW.get_error(out description)
  return value if error.no_error?

  description = String.new(description)
  raise "GLFW Error - #{description} (#{error})"
end
