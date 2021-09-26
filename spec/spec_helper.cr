require "glfw"
require "opengl"
require "spectator"
require "../src/gloop"

# Wraps GLFW calls with error checking.
private def checked
  value = yield
  error = LibGLFW.get_error(out description)
  return value if error.no_error?

  description = String.new(description)
  raise "GLFW Error - #{description} (#{error})"
end

# Initializes OpenGL enough for testing.
private def init_opengl
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
private def terminate_opengl
  LibGLFW.terminate
end

# Creates an OpenGL context.
private def create_context
  Gloop::Context.glfw
end

# Workaround for storing a single context in the global scope.
CONTEXT_WRAPPER = [] of Gloop::Context

# Shared context used for all tests.
def context
  CONTEXT_WRAPPER[0]
end

Spectator.configure do |config|
  config.before_suite do
    init_opengl
    CONTEXT_WRAPPER << create_context
  end

  config.after_suite { terminate_opengl }
end
