require "sdl"

private def sdl_error!
  ptr = LibSDL.get_error
  LibSDL.clear_error
  error = String.new(ptr)
  LibSDL.quit
  raise "SDL Error - #{error}"
end

# Initializes OpenGL enough for testing.
def init_opengl
  sdl_error! if LibSDL.init(LibSDL::INIT_VIDEO) < 0

  LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_MAJOR_VERSION, 4)
  LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_MINOR_VERSION, 6)
  LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_PROFILE_MASK, LibSDL::GLprofile::PROFILE_CORE)
  LibSDL.gl_set_attribute(LibSDL::GLattr::SDL_GL_CONTEXT_FLAGS, LibSDL::GLcontextFlag::DEBUG_FLAG)

  x = LibSDL::WindowPosition::UNDEFINED
  y = LibSDL::WindowPosition::UNDEFINED
  w = 640
  h = 480
  f = LibSDL::WindowFlags.flags(OPENGL, HIDDEN)

  window = LibSDL.create_window("Gloop", x, y, w, h, f)
  sdl_error! unless window
  context = LibSDL.gl_create_context(window)
  sdl_error! unless context
  sdl_error! if LibSDL.gl_make_current(window, context) < 0
end

# Cleans up resources used by OpenGL and SDL.
def terminate_opengl
  LibSDL.quit
end

# Creates an OpenGL context.
def create_context
  Gloop::Context.sdl
end
